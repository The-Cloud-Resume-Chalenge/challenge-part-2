data "aws_iam_policy_document" "lambda_assume_role_policy" {
  provider = aws.abd
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_dynamodb_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:PutItem",
      "dynamodb:Scan", # Permission to scan the table
      "dynamodb:DeleteItem"
    ]
    resources = [
      aws_dynamodb_table.basic-dynamodb-table.arn
    ]
  }
}

resource "aws_iam_role" "lambda_role" {
  provider           = aws.abd
  name               = "lambda-lambdaRole-waf"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  provider = aws.abd
  name     = "lambdaDynamoDBPolicy"
  policy   = data.aws_iam_policy_document.lambda_dynamodb_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attach" {
  provider   = aws.abd
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

