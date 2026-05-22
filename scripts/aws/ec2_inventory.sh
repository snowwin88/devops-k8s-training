#!/bin/bash

PROFILE="devops-admin"
REGION="us-east-2"

echo "EC2 Inventory"
echo "Region: $REGION"
echo "Profile: $PROFILE"
echo

aws ec2 describe-instances \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,PrivateIpAddress,SubnetId,VpcId,Tags[?Key=='Name'].Value|[0]]" \
  --output table
