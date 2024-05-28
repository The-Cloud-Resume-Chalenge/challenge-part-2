# Assuming your Python code and any dependencies are located within a directory named "lambda_function"
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/input" // Use path.module to refer to the current module directory
  output_path = "output/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  provider      = aws.abd
  filename      = data.archive_file.lambda.output_path
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "code.lambda_handler"

  environment {
    variables = {
      databaseName        = aws_dynamodb_table.basic-dynamodb-table.name
    }
  }

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = var.runtime
  timeout = 10
}


