resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name                      = "${local.prefix}-ecs"
  vpc_zone_identifier       = var.ec2_subnets
  capacity_rebalance        = true
  protect_from_scale_in     = false
  force_delete              = true
  max_size                  = var.ec2_max_count
  min_size                  = var.ec2_min_count
  desired_capacity          = var.ec2_desired_count
  health_check_grace_period = 120
    enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupMinSize",
    "GroupMaxSize",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances"
  ]
  dynamic "mixed_instances_policy" {
    for_each = var.use_mixed_instances_policy ? [1] : []
     content {
        instances_distribution {
            on_demand_base_capacity                     = var.on_demand_percentage
            on_demand_percentage_above_base_capacity    = var.on_demand_percentage
            spot_allocation_strategy                    = "lowest-price"
        }
        launch_template {
            launch_template_specification {
              launch_template_id = aws_launch_template.ecs_launch_template.id
              version            = aws_launch_template.ecs_launch_template.latest_version
            }
            override {
                instance_type = var.available_ec2_types[0]
            }
            override {
                instance_type = var.available_ec2_types[1]
            }
            override {
                instance_type = var.available_ec2_types[2]
            }
        }
     }
  }

  dynamic "launch_template" {
    for_each = var.use_mixed_instances_policy ? [] : [1]
      content {
        id = aws_launch_template.ecs_launch_template.id
        version = aws_launch_template.ecs_launch_template.latest_version
      }
  }

  dynamic "instance_refresh" {
    for_each = [for i in var.instance_refresh : i if i == "true"]
    content {
      strategy = "Rolling"
      preferences {
        instance_warmup = 120
        min_healthy_percentage = 90
      }
    }
  }
  tag {
      key                   = "REGION"
      value                 = upper(var.ecs_region)
      propagate_at_launch   = true
  }
  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

####################################################################################################

resource "aws_autoscaling_policy" "asg_scale_in_xme" {
  count = var.scaling_by_mem_and_cpu ? 0 : 1

  name                   = "${local.prefix}-ecs-ScaleInPolicy"
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"
  estimated_instance_warmup = 300
  autoscaling_group_name = "${local.prefix}-ecs"
  step_adjustment {
    scaling_adjustment = -1
    metric_interval_lower_bound = 0
  }
  depends_on = [ aws_autoscaling_group.ecs_autoscaling_group ]
}

resource "aws_cloudwatch_metric_alarm" "asg_scale_in_xme" {
  count = var.scaling_by_mem_and_cpu ? 0 : 1

  alarm_name          = "${local.prefix}-ecs-CPU-and-Mem-ReservationLow"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "1"
  datapoints_to_alarm = "1"

  metric_query {
    id                = "m1"
    return_data       = false
    metric {
      dimensions = {
        ClusterName   = "${local.prefix}"
      }
      metric_name     = "CPUReservation"
      namespace       = "AWS/ECS"
      period          = 300
      stat            = "Maximum"
    }
  }

  metric_query {
    id                = "m2"
    return_data       = false
    metric {
      dimensions = {
        ClusterName   = "${local.prefix}"
      }
      metric_name     = "MemoryReservation"
      namespace       = "AWS/ECS"
      period          = 300
      stat            = "Maximum"
    }
  }

  metric_query {
    expression        = "IF(m1<=70 AND m2<=70, 1, 0)"
    id                = "e1"
    label             = "if_cpu_and_mem_below_70"
    return_data       = true
  }

  alarm_description = "This metric monitors low CPU and Memory Reservation for the ${local.prefix} cluster"
  alarm_actions     = [aws_autoscaling_policy.asg_scale_in_xme[0].arn]
}

####################################################################################################

resource "aws_autoscaling_policy" "asg_scale_out_xme" {
  count = var.scaling_by_mem_and_cpu ? 0 : 1

  name                   = "${local.prefix}-ecs-ScaleOutPolicy"
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"
  estimated_instance_warmup = 300
  autoscaling_group_name = "${local.prefix}-ecs"
  step_adjustment {
    scaling_adjustment = 10
    metric_interval_lower_bound = 0 
  }
  depends_on = [ aws_autoscaling_group.ecs_autoscaling_group ]
}

resource "aws_cloudwatch_metric_alarm" "asg_scale_out_xme" {
  count = var.scaling_by_mem_and_cpu ? 0 : 1

  alarm_name          = "${local.prefix}-ecs-CPU-and-Mem-ReservationHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "1"
  datapoints_to_alarm = "1"

  metric_query {
    id                = "m1"
    return_data       = false
    metric {
      dimensions = {
        ClusterName   = "${local.prefix}"
      }
      metric_name     = "CPUReservation"
      namespace       = "AWS/ECS"
      period          = 300
      stat            = "Maximum"
    }
  }

  metric_query {
    id                = "m2"
    return_data       = false
    metric {
      dimensions = {
        ClusterName   = "${local.prefix}"
      }
      metric_name     = "MemoryReservation"
      namespace       = "AWS/ECS"
      period          = 300
      stat            = "Maximum"
    }
  }

  metric_query {
    expression        = "IF(m1>=85 OR m2>=85, 1, 0)"
    id                = "e1"
    label             = "if_cpu_or_mem_above_85"
    return_data       = true
  }

  alarm_description = "This metric monitors high CPU and Memory Reservation for the ${local.prefix} cluster"
  alarm_actions     = [aws_autoscaling_policy.asg_scale_out_xme[0].arn]
}

####################################################################################################

resource "aws_autoscaling_policy" "asg_scale_in_mem_and_cpu" {
  count = var.scaling_by_mem_and_cpu ? 1 : 0

  name                   = "${local.prefix}-ecs-ScaleInPolicy"
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"
  estimated_instance_warmup = 60
  autoscaling_group_name = "${local.prefix}-ecs"
  step_adjustment {
    scaling_adjustment = -1
    metric_interval_lower_bound = 0
  }
  depends_on = [ aws_autoscaling_group.ecs_autoscaling_group ]
}

resource "aws_cloudwatch_metric_alarm" "asg_scale_in_mem_and_cpu" {
  count = var.scaling_by_mem_and_cpu ? 1 : 0

  alarm_name          = "${local.prefix}-ecs-CPU-and-Mem-ReservationLow"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "1"
  datapoints_to_alarm = "1"

  metric_query {
    id                = "m1"
    return_data       = false
    metric {
      dimensions = {
        ClusterName   = "${local.prefix}"
      }
      metric_name     = "CPUReservation"
      namespace       = "AWS/ECS"
      period          = 300
      stat            = "Maximum"
    }
  }

  metric_query {
    id                = "m2"
    return_data       = false
    metric {
      dimensions = {
        ClusterName   = "${local.prefix}"
      }
      metric_name     = "MemoryReservation"
      namespace       = "AWS/ECS"
      period          = 300
      stat            = "Maximum"
    }
  }

  metric_query {
    expression        = "IF(m1<=70 AND m2<=70, 1, 0)"
    id                = "e1"
    label             = "if_cpu_and_mem_below_70"
    return_data       = true
  }

  alarm_description = "This metric monitors low CPU and Memory Reservation for the ${local.prefix} cluster"
  alarm_actions     = [aws_autoscaling_policy.asg_scale_in_mem_and_cpu[0].arn]
}

####################################################################################################

resource "aws_autoscaling_policy" "asg_scale_out_mem_and_cpu" {
  count = var.scaling_by_mem_and_cpu ? 1 : 0

  name                   = "${local.prefix}-ecs-ScaleOutPolicy"
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"
  estimated_instance_warmup = 60
  autoscaling_group_name = "${local.prefix}-ecs"
  step_adjustment {
    scaling_adjustment = 2
    metric_interval_lower_bound = 0 
  }
  depends_on = [ aws_autoscaling_group.ecs_autoscaling_group ]
}

resource "aws_cloudwatch_metric_alarm" "asg_scale_out_mem_and_cpu" {
  count = var.scaling_by_mem_and_cpu ? 1 : 0

  alarm_name          = "${local.prefix}-ecs-CPU-and-Mem-ReservationHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "1"
  datapoints_to_alarm = "1"

  metric_query {
    id                = "m1"
    return_data       = false
    metric {
      dimensions = {
        ClusterName   = "${local.prefix}"
      }
      metric_name     = "CPUReservation"
      namespace       = "AWS/ECS"
      period          = 300
      stat            = "Maximum"
    }
  }

  metric_query {
    id                = "m2"
    return_data       = false
    metric {
      dimensions = {
        ClusterName   = "${local.prefix}"
      }
      metric_name     = "MemoryReservation"
      namespace       = "AWS/ECS"
      period          = 300
      stat            = "Maximum"
    }
  }

  metric_query {
    expression        = "IF(m1>=85 OR m2>=85, 1, 0)"
    id                = "e1"
    label             = "if_cpu_or_mem_above_85"
    return_data       = true
  }

  alarm_description = "This metric monitors high CPU and Memory Reservation for the ${local.prefix} cluster"
  alarm_actions     = [aws_autoscaling_policy.asg_scale_out_mem_and_cpu[0].arn]
}



####################################################################################################

resource "aws_launch_template" "ecs_launch_template" {
  name = "${local.prefix}-ecs-instance"
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_iam_instance_profile.name
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
	encrypted = true
        volume_size = var.volume_size
        volume_type = var.volume_type
    }
  }

  # Conditionally include an additional volume
  dynamic "block_device_mappings" {
    for_each = var.enable_additional_volume ? [1] : []

    content {
      device_name = "/dev/xvdb"
      ebs {
        encrypted = true
        volume_size = var.additional_volume_size
        volume_type = var.volume_type
      }
    }
  }

  image_id = data.aws_ami.amazon-linux-2023.id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_ssh_key_name
  update_default_version = true
  
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    http_endpoint               = "enabled"
  }

  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.ec2_security_groups
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(
        {
            Name              = "${local.prefix}-ecs-instance"
            TERRAFORM_MANAGED = "TRUE"
            patchmanagement = "Replacement"
        },
        var.tags
    )
  }
  tag_specifications {
    resource_type = "volume"
    tags = merge(
        {
            Name              = "${local.prefix}-ecs-volume"
            TERRAFORM_MANAGED = "TRUE"
        },
        var.tags
    )
  }

  user_data = base64encode(templatefile("${path.module}/ecs_instance_bootstrap.sh.tpl", {
    ECS_CLUSTER_NAME  = local.prefix,
    ECS_REGION = var.ecs_region,
    ENABLE_ADDITIONAL_VOLUME = var.enable_additional_volume
  }))
}

