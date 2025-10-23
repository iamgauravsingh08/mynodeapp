provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "mynodeapp22102025"
    key            = "us-east-1/ecs_cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}