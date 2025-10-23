#!/bin/bash -x
cat << EOF >> /etc/ecs/ecs.config
ECS_CLUSTER=${ECS_CLUSTER_NAME}
ECS_BACKEND_HOST=

# See Amazon ECS Container Agent Configuration here:
#   https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html

# Log level written to the stdout
ECS_LOGLEVEL=info

# Whether to exit for ECS agent updates when they are requested
ECS_UPDATES_ENABLED=false

# Remove Docker container, data, logs for stopped ECS Task
ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=3h

# Interval between container graceful stop and force kill
ECS_CONTAINER_STOP_TIMEOUT=30s

# Set image caching for quicker task spinup. The cleanup settings will have to be commented.
ECS_IMAGE_PULL_BEHAVIOR=once

# Interval between image cleanup cycles
ECS_IMAGE_CLEANUP_INTERVAL=30m

# Minimum interval between image pull and cleanup
ECS_IMAGE_MINIMUM_CLEANUP_AGE=1h

EOF

sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Install Latest Kernel Headers
sudo yum install -y kernel-devel-$(uname -r)

# Install AWS CLI
sudo yum install -y awscli

# Install jq
sudo yum install -y jq

# Fetch IMDS Token
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Fetch the instance profile name
AWS_INSTANCE_PROFILE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/)

# Fetch temporary credentials
AWS_ACCESS_KEY_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/$AWS_INSTANCE_PROFILE | grep 'AccessKeyId' | awk -F'"' '{print $4}')
AWS_SECRET_ACCESS_KEY=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/$AWS_INSTANCE_PROFILE | grep 'SecretAccessKey' | awk -F'"' '{print $4}')
AWS_SESSION_TOKEN=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/$AWS_INSTANCE_PROFILE | grep 'Token' | awk -F'"' '{print $4}')

# Export credentials for use in this script
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

# Attach 2nd Volume if configured
if [[ "${ENABLE_ADDITIONAL_VOLUME}" == "true" ]]; then
	echo "Setting up additional volume..."
	sudo mkfs -t ext4 /dev/xvdb
	sudo mkdir -p /spark-tmp
	mount /dev/xvdb /spark-tmp
	echo "/dev/xvdb /spark-tmp ext4 defaults,nofail 0 2" >> /etc/fstab
fi
#!/bin/bash -x
cat << EOF >> /etc/ecs/ecs.config
ECS_CLUSTER=${ECS_CLUSTER_NAME}
ECS_BACKEND_HOST=

# See Amazon ECS Container Agent Configuration here:
#   https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html

# Log level written to the stdout
ECS_LOGLEVEL=info

# Whether to exit for ECS agent updates when they are requested
ECS_UPDATES_ENABLED=false

# Remove Docker container, data, logs for stopped ECS Task
ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=3h

# Interval between container graceful stop and force kill
ECS_CONTAINER_STOP_TIMEOUT=30s

# Set image caching for quicker task spinup. The cleanup settings will have to be commented.
ECS_IMAGE_PULL_BEHAVIOR=once

# Interval between image cleanup cycles
ECS_IMAGE_CLEANUP_INTERVAL=30m

# Minimum interval between image pull and cleanup
ECS_IMAGE_MINIMUM_CLEANUP_AGE=1h

EOF

# Install Latest Kernel Headers
sudo yum install -y kernel-devel-$(uname -r)

# Install AWS CLI
sudo yum install -y awscli

# Install jq
sudo yum install -y jq

# Fetch IMDS Token
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Fetch the instance profile name
AWS_INSTANCE_PROFILE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/)

# Fetch temporary credentials
AWS_ACCESS_KEY_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/$AWS_INSTANCE_PROFILE | grep 'AccessKeyId' | awk -F'"' '{print $4}')
AWS_SECRET_ACCESS_KEY=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/$AWS_INSTANCE_PROFILE | grep 'SecretAccessKey' | awk -F'"' '{print $4}')
AWS_SESSION_TOKEN=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/$AWS_INSTANCE_PROFILE | grep 'Token' | awk -F'"' '{print $4}')

# Export credentials for use in this script
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

# Attach 2nd Volume if configured
if [[ "${ENABLE_ADDITIONAL_VOLUME}" == "true" ]]; then
	echo "Setting up additional volume..."
	sudo mkfs -t ext4 /dev/xvdb
	sudo mkdir -p /spark-tmp
	mount /dev/xvdb /spark-tmp
	echo "/dev/xvdb /spark-tmp ext4 defaults,nofail 0 2" >> /etc/fstab
fi
