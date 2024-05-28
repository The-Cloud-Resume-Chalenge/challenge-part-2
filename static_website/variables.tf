variable "profile" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "use_aws_profile" {
  description = "Set to true to use AWS profile, or false to use access keys"
  type        = bool
}

variable "region_master" {
  type = string
}


variable "api_endpoint" {
  type = string
}

variable "endpoint" {
  type = string
}

variable "basic_dynamodb_table" {
  type = string
}

variable "function_name" {
  type = string
}

variable "runtime" {
  type = string
}


# =============================== Outputs ======================================

output "api_endpoint" {
  description = "The end_point of the API"
  value       = "${aws_apigatewayv2_api.lambda.api_endpoint}/${var.endpoint}/${aws_lambda_function.lambda.function_name}"
}

