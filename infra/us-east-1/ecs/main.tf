module "ecs_cluster" {
  source                 = "../../ecs_cluster"
  project                = var.project
  stack                  = var.stack
  cluster_revision       = var.cluster_revision
  ecs_region             = var.ecs_cluster_ecs_region
  ec2_subnets            = var.ecs_cluster_ec2_subnet_id
  ec2_security_groups    = var.ecs_cluster_ec2_security_groups
  ec2_ssh_key_name       = var.ecs_cluster_ec2_ssh_key_name
  ec2_instance_type      = var.ecs_cluster_ec2_instance_type
  ec2_ami                = data.aws_ami.amazon-linux-2023.id
  ec2_max_count          = var.ecs_cluster_ec2_max_count
  ec2_min_count          = var.ecs_cluster_ec2_min_count
  ec2_desired_count      = var.ecs_cluster_ec2_desired_count
  on_demand_percentage   = var.ecs_cluster_on_demand_percentage
  scaling_by_mem_and_cpu = var.ecs_cluster_scaling_by_mem_and_cpu
  available_ec2_types    = var.ecs_cluster_available_ec2_types
  instance_refresh       = var.ecs_cluster_instance_refresh
  tags                   = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "capacity_provider_group" {
  cluster_name       = module.ecs_cluster.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]

}
resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "${var.project}-${var.stack}-${var.cluster_revision}"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = module.ecs_cluster.ecs_autoscaling_group.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {

      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "DISABLED"
      target_capacity           = 90
      instance_warmup_period    = 60
    }
  }
}