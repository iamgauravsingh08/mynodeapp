variable "project" {
  type = string
  default = "DevOps"
}
variable "stack" {
  type        = string
  default = "Dev"
  description = "Put stack name here. Use naming like username, dev, stage, prod"
}
variable "cluster_revision" {
  type        = string
  default = "r1"
  description = "Revision of cluster"
}
variable "ami_search_pattern" {
  type        = string
  default = "al2023-ami-ecs-hvm-20*"
  description = "uses to find appropriate most recent image to use for a new instance"
}
# "al2023*" amazon linux 2023
variable "ami_owner" {
  type        = list(string)
  default = [ "amazon", "self" ]
  description = "list of possible owners for image to search"
}
variable "ecs_cluster_ec2_instance_type" {
  type        = string
  default = "t3.medium"
  description = "EC2 Instance Type for ECS Cluster; see LaunchTemplate.LaunchTemplateData Im"
}

variable "ecs_cluster_ecs_region" {
  type        = string
  default = "us-east-1"
  description = "Default Region"
}
variable "ecs_cluster_ec2_max_count" {
  type        = number
  default = 3
  description = "Max number of EC2 instances in ECS Cluster; see AutoScalingGroup.MaxSize"
}
variable "ecs_cluster_ec2_min_count" {
  type        = number
  default = 1
  description = "Min number of EC2 instances in ECS Cluster; see AutoScalingGroup.MinSize"
}
variable "ecs_cluster_ec2_desired_count" {
  type        = number
  default = 1
  description = "Desired number of EC2 instances in ECS Cluster; see AutoScalingGroup.DesiredSize"
}
variable "ecs_cluster_on_demand_percentage" {
  type        = number
  default = 25
  description = "Number of percentage of on demand instances to use"
}
variable "ecs_cluster_scaling_by_mem_and_cpu" {
  type        = bool
  description = ""
  default     = "false"
}
variable "ecs_cluster_available_ec2_types" {
  type        = list(string)
  default = [ "t3.medium", "t2.medium", "t2.large" ]
  description = "list of available instances type to use as spot"
}
variable "ecs_cluster_ec2_ssh_key_name" {
  type        = string
  default = "devops-us-east-1"
  description = "key name for instance"
}
variable "ecs_cluster_ec2_subnet_id" {
  type        = set(string)
  default = [ "subnet-09ce87af2941437f2","subnet-0c7723dbb84728970" ]
  description = "subnet id"
}
variable "ecs_cluster_ec2_security_groups" {
  type        = set(string)
  default = [ "sg-06eb8d5cf23d0c446" ]
  description = "ec2 security groups"
}

variable "ecs_cluster_instance_refresh" {
  type        = set(string)
  default = [ "true" ]
  description = "this is used to decide if the cluster will have instance refresh"
}
variable "tags" {
  type = map(any)
  default = {
    Component = "ECS"
  }
}