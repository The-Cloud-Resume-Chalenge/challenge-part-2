resource "aws_apigatewayv2_api" "lambda" {
  provider      = aws.abd
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins     = ["*"]
    allow_headers     = []
    allow_methods     = []
    expose_headers    = []
    max_age           = 0
    allow_credentials = false
  }
}



resource "aws_apigatewayv2_integration" "visitors" {
  provider = aws.abd
  api_id   = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}


# Define the stage with auto_deploy enabled.
resource "aws_apigatewayv2_stage" "lambda" {
  provider    = aws.abd
  api_id      = aws_apigatewayv2_api.lambda.id
  name        = var.endpoint
  auto_deploy = true

  # Add a dependency on the route to ensure it is created before the stage is deployed and to trigger deployment on changes.
  depends_on = [aws_apigatewayv2_route.visitors]
}

resource "aws_apigatewayv2_route" "visitors" {
  provider = aws.abd
  api_id   = aws_apigatewayv2_api.lambda.id

  route_key = "ANY /${aws_lambda_function.lambda.function_name}" // Add '/visitor' to the route
  target    = "integrations/${aws_apigatewayv2_integration.visitors.id}"
}


resource "aws_lambda_permission" "api_gw" {
  provider      = aws.abd
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
