locals {
  users = [
    {
      name              = "johnnymax"
      force_destroy     = true
      create_access_key = true
      tags = {
        Owner = "dev-team"
      }
    },
    {
      name              = "Victor-Teixeira"
      force_destroy     = true
      create_access_key = true
      tags = {
        Owner = "dev-team"
      }
    }
  ]

  groups = [
    {
      name        = "Desenvolvedor"
      description = "Grupo de desenvolvedores"
      users       = ["johnnymax", "Victor-Teixeira"]
      policy_arns = [
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
        module.iam.policy_arns["Policy-customizada"]
      ]
    }
  ]

  policies = [
    {
      name        = "Policy-customizada"
      description = "Permissão customizada EC2"
      policy      = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Effect   = "Allow",
            Action   = ["ec2:Describe*"],
            Resource = "*"
          }
        ]
      })
    }
  ]
}


module "iam" {
  source   = "../../modules/iam"
  users    = local.users
  policies = local.policies
  groups = local.groups
}