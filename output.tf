output "this_iam_role_arn" {
  value = element(concat(aws_iam_role.this.*.arn, [""]), 0)
}

output "this_iam_role_name" {
  value = element(concat(aws_iam_role.this.*.name, [""]), 0)
}
