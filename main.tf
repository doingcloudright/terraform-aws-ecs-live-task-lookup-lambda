# Zip the lambda dir
data "archive_file" "lookup_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lookup_lambda"
  output_path = "${path.module}/lookup.zip"
}

#
# lookup_type lambda
#
resource "aws_lambda_function" "lambda_lookup" {
  count            = var.create ? 1 : 0
  function_name    = var.name
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  filename         = "${path.module}/lookup.zip"
  source_code_hash = data.archive_file.lookup_zip.output_base64sha256
  role   = element(concat(aws_iam_role.this.*.arn, [""]), 0)

  publish = true
  tags    = var.tags

  lifecycle {
    ignore_changes = [filename]
  }
}

# Policy for the ecs lookup lambda
data "aws_iam_policy_document" "policy" {
  count = var.create ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:ListTaskDefinitions",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*"
    ]

    effect = "Allow"
  }

  statement {
    actions = ["logs:PutLogEvents"]

    resources = [
      "*"
    ]

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "trust_policy" {
  count              = var.create ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

# Role for lambda to lookup the ecs cluster & services
resource "aws_iam_role" "this" {
  count              = var.create ? 1 : 0
  name_prefix        = "ecslambdalookup"
  description        = "Role permitting Lambda functions to be invoked from Lambda"
  assume_role_policy = data.aws_iam_policy_document.trust_policy[0].json
}

resource "aws_iam_role_policy" "this" {
  count  = var.create ? 1 : 0
  role   = element(concat(aws_iam_role.this.*.id, [""]), 0)
  policy = data.aws_iam_policy_document.policy[0].json
}
