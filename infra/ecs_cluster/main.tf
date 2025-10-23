data "aws_ami" "amazon-linux-2023" {
  most_recent                    = true

  filter {
    name                         = "name"
    values                       = [var.ami_search_pattern]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]  # Ensure the architecture is x86_64
  }

  owners                         = var.ami_owner
}
