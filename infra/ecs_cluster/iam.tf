resource "aws_iam_instance_profile" "ecs_iam_instance_profile" {
  name = "${local.prefix}-ecs-instance"
  role = aws_iam_role.ecs_iam_role.name
}

resource "aws_iam_role" "ecs_iam_role" {
  name = "${local.prefix}-ecs-instance"
  assume_role_policy = jsonencode({
    Statement = {
      Action = ["sts:AssumeRole"]
      Principal = {
        Service = ["ec2.amazonaws.com"]
      }
      Effect = "Allow"
    }
    Version = "2012-10-17"
  })
  tags = merge(var.tags)
}

data "aws_iam_policy_document" "ssm_ec2_onboarding" {
  # This policy is mostly copied from default one
  statement {
    sid    = "AllowSSMActions"
    effect = "Allow"

    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowEC2Messages"
    effect = "Allow"

    actions = [
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowS3Actions"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]

    resources = [
        "arn:aws:s3:::xen-packages-other",
        "arn:aws:s3:::xen-packages-other/*"
    ]
  }

  statement {
    sid    = "SSMUploadLogsS3forNRT"
    effect = "Allow"

    actions = [
      "s3:Describe*",
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3-object-lambda:Get*",
      "s3-object-lambda:List*"
    ]

    resources = [
      "arn:aws:s3:::xenial-nrt-dev-automation-logs",
      "arn:aws:s3:::xenial-nrt-dev-automation-logs/*",
      "arn:aws:s3:::xenial-nrt-stage-automation-logs",
      "arn:aws:s3:::xenial-nrt-stage-automation-logs/*",
      "arn:aws:s3:::xenial-nrt-prod-automation-logs",
      "arn:aws:s3:::xenial-nrt-prod-automation-logs/*",
      "arn:aws:s3:::xenial-nrt-uat-automation-logs",
      "arn:aws:s3:::xenial-nrt-uat-automation-logs/*"
    ]
  }

  statement {
    sid    = "AllowSSMMessages"
    effect = "Allow"

    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }

  statement {
    sid       = "AllowEC2DescribeInstanceStatus"
    effect    = "Allow"
    actions   = ["ec2:DescribeInstanceStatus"]
    resources = ["*"]
  }

}

resource "aws_iam_policy" "ssm_ec2_onboarding" {
  name   = "SSMECSOnboardingPolicyCustom-${var.stack}-${var.project}-${var.cluster_revision}"
  policy = data.aws_iam_policy_document.ssm_ec2_onboarding.json
}

data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy" "AmazonECS_FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_iam_role_has_AmazonEC2ContainerServiceforEC2Role" {
  role       = aws_iam_role.ecs_iam_role.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn
}

resource "aws_iam_role_policy_attachment" "ecs_iam_role_has_AmazonECS_FullAccess" {
  role       = aws_iam_role.ecs_iam_role.name
  policy_arn = data.aws_iam_policy.AmazonECS_FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ecs_iam_role.name
  policy_arn = aws_iam_policy.ssm_ec2_onboarding.arn
}
