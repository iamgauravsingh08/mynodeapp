data "terraform_remote_state" "dev-dmb-r1" {
  backend = "s3"
  config = {
    bucket = "mynodeapp22102025"
    key = "us-east-1/ecs_cluster/terraform.tfstate"
    region = "us-east-1"
  }
}