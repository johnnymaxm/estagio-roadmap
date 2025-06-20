locals {
  users = [
     {
       name = "Johnny Max"
     }
  ]


  groups = []

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