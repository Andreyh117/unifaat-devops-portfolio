resource "aws_dynamodb_table" "lock" {
  name         = "technova-tf-lock-6325231"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = { Name = "technova-tf-lock" }
}
