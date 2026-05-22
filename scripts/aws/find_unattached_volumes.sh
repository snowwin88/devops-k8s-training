#!/bin/bash

PROFILE="devops-admin"
REGION="us-east-2"

echo "Unattached EBS volumes"
echo

aws ec2 describe-volumes \
  --region "$REGION" \
  --profile "$PROFILE" \
  --filters "Name=status,Values=available" \
  --query "Volumes[*].[VolumeId,Size,VolumeType,AvailabilityZone,CreateTime]" \
  --output table
