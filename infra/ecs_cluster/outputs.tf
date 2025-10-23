output "cluster_arn" {
  description = "ARN of ECS Cluster"
  value       = aws_ecs_cluster.ecs_cluster.arn
}

output "cluster_id" {
  description = "The ID of the created ECS cluster."
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "cluster_name" {
  description = "The name of the created ECS cluster."
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "use_static_sg" {
  value = var.use_static_sg
}
output "enable_additional_volume" {
  value = var.enable_additional_volume
}
output "vpc_id" {
  value = var.vpc_id
}
output "vpc_cidr" {
  value = var.vpc_cidr
}
output "use_mixed_instances_policy" {
  value = var.use_mixed_instances_policy
}

output "ecs_autoscaling_group" {
  description = "The ECS autoscaling group"
  value       = aws_autoscaling_group.ecs_autoscaling_group
}
