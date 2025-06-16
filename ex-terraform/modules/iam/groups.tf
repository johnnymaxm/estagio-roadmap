resource "aws_iam_group" "this" {
  for_each = { for group in var.groups : group.name => group }

  name = each.value.name
  path = "/"
}

resource "aws_iam_group_policy_attachment" "this" {
  for_each = {
    for group in var.groups : "${group.name}-0" => {
      name        = group.name
      policy_arn = group.policy_arns[0]
    }
  }

  group      = aws_iam_group.this[each.value.name].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_group_membership" "this" {
  for_each = { for group in var.groups : group.name => group }

  name  = "membership-${each.key}"
  users = each.value.users
  group = aws_iam_group.this[each.key].name
}
