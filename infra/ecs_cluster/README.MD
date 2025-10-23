## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.ecs_autoscaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_ecs_capacity_provider.capacity_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_iam_instance_profile.ecs_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ssm_ec2_onboarding](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_iam_role_has_AmazonEC2ContainerServiceforEC2Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_iam_role_has_AmazonECS_FullAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.ecs_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_iam_policy.AmazonEC2ContainerServiceforEC2Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.AmazonECS_FullAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.ssm_ec2_onboarding](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.ecs_optimized_amazon_linux_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_available_ec2_types"></a> [available\_ec2\_types](#input\_available\_ec2\_types) | Set of strings with available instances type to use as spot | `set(string)` | <pre>[<br>  "t3.medium",<br>  "t3.large",<br>  "t3a.medium",<br>  "t3a.large"<br>]</pre> | no |
| <a name="input_carbon_black_code"></a> [carbon\_black\_code](#input\_carbon\_black\_code) | Carbon black company code | `string` | `"XXXXXXXXXXXXXXXX"` | no |
| <a name="input_carbon_black_sensor_kit"></a> [carbon\_black\_sensor\_kit](#input\_carbon\_black\_sensor\_kit) | Carbon black sensor kit | `string` | `"XXXXXXXXXXXXXXXX"` | no |
| <a name="input_cluster_revision"></a> [cluster\_revision](#input\_cluster\_revision) | Cluster Revision | `string` | `"r1"` | yes |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | EC2 Instance Type for ECS Cluster; see LaunchTemplate.LaunchTemplateData.InstanceType | `string` | `"t3.medium"` | no |
| <a name="input_ec2_max_count"></a> [ec2\_max\_count](#input\_ec2\_max\_count) | Max number of EC2 instances in ECS Cluster; see AutoScalingGroup.MaxSize | `number` | `2` | yes |
| <a name="input_ec2_min_count"></a> [ec2\_min\_count](#input\_ec2\_min\_count) | Min number of EC2 instances in ECS Cluster; see AutoScalingGroup.MinSize | `number` | `1` | yes |
| <a name="input_ec2_desired_count"></a> [ec2\_desired\_count](#input\_ec2\_desired\_count) | Desired number of EC2 instances in ECS Cluster; see AutoScalingGroup.DesiredSize | `number` | `1` | yes |
| <a name="input_ec2_security_groups"></a> [ec2\_security\_groups](#input\_ec2\_security\_groups) | Security Group IDs to associate EC2 instances with; see LaunchTemplate.LaunchTemplateData.SecurityGroupIds | `set(string)` | n/a | yes |
| <a name="input_ec2_ssh_key_name"></a> [ec2\_ssh\_key\_name](#input\_ec2\_ssh\_key\_name) | Name of SSH key pair to connect on EC2 instance; see LaunchTemplate.LaunchTemplateData.KeyName | `string` | n/a | yes |
| <a name="input_ec2_subnets"></a> [ec2\_subnets](#input\_ec2\_subnets) | Subnet IDs to launch EC2 instances for ECS Cluster; see AutoScalingGroup.VPCZoneIdentifier | `set(string)` | n/a | yes |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | Enables EBS encryption on the volume | `bool` | `false` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. encrypted must be set to true when this is set. | `string` | `null` | no |
| <a name="input_on_demand_percentage"></a> [on\_demand\_percentage](#input\_on\_demand\_percentage) | Number of prsents of on demand instances to use, default 0 means 100% spot will be used | `number` | `0` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `"xenial"` | no |
| <a name="input_stack"></a> [stack](#input\_stack) | Put stack name here. Use naming like username, dev, stage, prod | `string` | `"dev"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | `{}` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | The size of the volume in gigabytes. | `number` | `30` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | The volume type. Can be standard, gp2, gp3, io1, io2, sc1 or st1 | `string` | `"gp3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN of ECS Cluster |

## Locals
-${var.cluster_revision} can be removed from the beginning or end of prefix depending on what you would like the cluster to be named
