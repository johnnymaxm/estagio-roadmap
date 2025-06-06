# Data sources
data "aws_caller_identity" "current" {}

locals {
  project_name = "estagio"
  environment = "dev"

  ecr_repositories = [
    "estagio"
  ]

  users_eks = [
    "cloud_user"
  ]
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.21.0"

    name = "${local.project_name}-${local.environment}-vpc"
    cidr = "10.0.0.0/16"

    azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

    map_public_ip_on_launch  = true
    
    enable_nat_gateway = true
    single_nat_gateway = true
    one_nat_gateway_per_az = false

    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Environment = local.environment
        "kubernetes.io/cluster/${local.project_name}-cluster" = "shared"
    }

    public_subnet_tags = {
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${local.project_name}-cluster" = "shared"
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/${local.project_name}-cluster" = "shared"
    }
}

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"
  
  for_each = toset(local.ecr_repositories)

  repository_name = "${local.project_name}-${each.value}"
  repository_image_tag_mutability = "MUTABLE" 
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "delete images without tags",
        selection = {
          tagStatus     = "untagged",
          countType     = "imageCountMoreThan",
          countNumber   = 1
        },
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2,
        description  = "delete images more than 10",
        selection = {
          tagStatus     = "any",
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = local.environment
    Repository  = each.value
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20"

  cluster_name    = "${local.project_name}-cluster"
  cluster_version = "1.33"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }

  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3a.medium", "t3.medium"]
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      
    }
  }

  eks_managed_node_groups = {
    apps = {
      min_size     = 2
      max_size     = 10
      desired_size = 2
      instance_types = ["t3a.medium"]
      capacity_type  = "ON_DEMAND"
    }
    default = {
      min_size     = 1
      max_size     = 10
      desired_size = 1
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  access_entries = {
    for user in local.users_eks : user => {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
