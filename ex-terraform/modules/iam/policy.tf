resource "aws_iam_policy" "this" {
  for_each = { for policy in var.policies : policy.name => policy }

  name        = each.value.name
  description = each.value.description
  policy      = each.value.policy
}