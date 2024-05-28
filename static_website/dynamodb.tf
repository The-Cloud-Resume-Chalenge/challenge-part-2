resource "aws_dynamodb_table" "basic-dynamodb-table" {
  provider     = aws.abd
  name         = var.basic_dynamodb_table
  billing_mode = "PAY_PER_REQUEST" // No read_capacity or write_capacity needed
  hash_key     = "stat"

  attribute {
    name = "stat"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}

