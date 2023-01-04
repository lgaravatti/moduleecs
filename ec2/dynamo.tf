resource "aws_dynamodb_table" "dynamo-state-lockfile" {
  hash_key = "LockID"
  name     = "terraform-table-tfstate"
  read_capacity = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}