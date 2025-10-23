/* ---------- Search ami ---------- */

variable "ami_search_pattern" {
  type = string
  description = "uses to find appropriate most recent image to use for a new instance"
  default = "al2023-ami-ecs-*"
}
variable "ami_owner" {
  description = "list of possible owners for image to search"
  default = [
    "amazon",
    "self"
  ]
}

variable "vpc_id" {
  description = "Default VPC"
  default = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  default = ""
}

variable "use_static_sg" {
  type = bool
  description = "Enable use of a static security group or not"
  default = false
}

variable "project" {
  type = string
  default = "null"
}

variable "stack" {
  type = string
  default = "dev"
  description = "Stack Name"
}

variable "cluster_revision" {
  type = string
  description = "Revision of Cluster"
}

variable "ecs_region" {
  type = string
  description = "Default Region"
}

variable "ec2_subnets" {
  type = set(string)
  description = "Subnet to launch ec2 instance to host cluster"
}

variable "ec2_security_groups" {
  type = set(string)
  description = "security groups for cluster host EC2 to live in"
}

variable "ec2_ssh_key_name" {
  type = string
  description = "ssh key for host EC2 instance"
}

variable "ec2_instance_type" {
  type = string
  description = "Instance type for cluster hosting EC2 instance"
}

variable "ec2_ami" {
  type        = string
  description = "AMI for LaunchTemplate"
  default = ""
}

variable "ec2_max_count" {
  type = number
  description = "Max number of host instances"
  default = 1
}

variable "ec2_min_count" {
  type = number
  description = "Minimal number of host EC2 instances"
  default = 1
}

variable "ec2_desired_count" {
  type = number
  description = "Desired number of host EC2 instances"
  default = 1
}

variable "on_demand_percentage" {
  type = number
  description = "Percentage of preset instances to use"
  default = 100
}

variable "scaling_by_mem_and_cpu" {
  type = bool
  description = "This is used to decide if the cluster is scaling by only memory, or memory AND cpu usage"
  default = "true"
}

variable "volume_size" {
  type = number
  description = "Size of host EC2 volume in GB"
  default = 30
}

variable "additional_volume_size" {
  type = number
  description = "Size of host Additional EC2 volume in GB"
  default = 200
}

variable "volume_type" {
  type = string
  description = "Host EC2 instnce volume type"
  default = "gp3"
}
variable "encrypted" {
  type = bool
  description = "Enables EBS encryption on the volume"
  default = true
}
variable "kms_key_id" {
  type = string
  description = "The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. encrypted must be set to true when this is set."
  default = null
}



variable "available_ec2_types" {
  type = list(string)
  description = "Set of strings with available instances type to use as spot"
  default = [
    "t3.medium",
    "t3.large",
    "t3a.medium",
    "t3a.large"
  ]
}

variable "ecs_task_inline_policy" {
  type = string
  default = null
  description = "AWS IAM Inline Policy Document to attach to the AWS IAM Role of an AWS ECS Task"
}

variable "instance_refresh" {
  type = set(string)
  description = "This is used to decide if the cluster will have instance refresh"
  default = ["false"]
}

variable "tags" {
  type = map(any)
  default = {}
}

variable "enable_additional_volume" {
  description = "If you need an additional volume attached or not"
  type = bool
  default = false
}

variable "use_mixed_instances_policy" {
  description = "If you need an additional instances instead of the ones defined in the LT"
  type = bool
  default = true
}

