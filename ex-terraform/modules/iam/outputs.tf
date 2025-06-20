output "policy_arns" {
  value = {
    for k, v in aws_iam_policy.this : k => v.arn
  }
  description = "ARNs de políticas customizadas criadas no módulo"
}

output "custom_policy_arn" {
  value = aws_iam_policy.this["Policy-customizada"].arn
  description = "ARN da política customizada"
}