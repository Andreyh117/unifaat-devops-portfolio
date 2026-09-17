output "bucket_name" {
  value = var.bucket_name
}
output "dynamodb_table" {
  value = aws_dynamodb_table.lock.name
}
