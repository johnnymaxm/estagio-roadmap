resource "aws_iam_user" "this" {
  for_each = { for user in var.users : user.name => user }

  name          = each.value.name
  force_destroy = each.value.force_destroy
  tags          = each.value.tags
}

resource "aws_iam_access_key" "this" {
  for_each = { for user in var.users : user.name => user if user.create_access_key }

  user = each.value.name
  depends_on = [aws_iam_user.this]
}