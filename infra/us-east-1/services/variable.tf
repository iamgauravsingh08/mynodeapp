variable "cluster_name" {
  type = string
  default = "DevOps-Dev-r1"
}
variable "vpc_id" {
  type = string
  default = "vpc-0d8abcba59c6e4762"
}
variable "image_uri" {
  type = string
  default = "295191712839.dkr.ecr.us-east-1.amazonaws.com/nodeapp:v1"
}
variable "subnets_ids" {
  type        = set(string)
  default = [ "subnet-09ce87af2941437f2","subnet-0c7723dbb84728970" ]
  description = "subnet id"
}
variable "security_groups" {
  type = list(string)
  default = [ "sg-06eb8d5cf23d0c446" ]
}
