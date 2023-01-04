provider "aws" {
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    # Lembre de trocar o bucket para o seu, não pode ser o mesmo nome
    bucket = "garavatti-s3"
    #dynamodb_table = "terraform-table-tfstate"
    key    = "terraform-test.tfstate"
    region = "us-east-1"
  }
}