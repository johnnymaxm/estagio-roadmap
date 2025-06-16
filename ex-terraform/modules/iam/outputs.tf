output "policy_arns" {
  value = {
    for k, v in aws_iam_policy.this : k => v.arn
  }
  description = "ARNs de políticas customizadas criadas no módulo"
}