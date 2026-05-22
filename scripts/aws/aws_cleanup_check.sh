#!/bin/bash

PROFILE="devops-admin"
REGION="us-east-2"

echo "=== Running EC2 Instances ==="
aws ec2 describe-instances \
  --region "$REGION" \
  --profile "$PROFILE" \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key=='Name'].Value|[0]]" \
  --output table

echo
echo "=== Unattached EBS Volumes ==="
aws ec2 describe-volumes \
  --region "$REGION" \
  --profile "$PROFILE" \
  --filters "Name=status,Values=available" \
  --query "Volumes[*].[VolumeId,Size,VolumeType,AvailabilityZone]" \
  --output table

echo
echo "=== Load Balancers ==="
aws elbv2 describe-load-balancers \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "LoadBalancers[*].[LoadBalancerName,Type,Scheme,State.Code,DNSName]" \
  --output table

echo
echo "=== EKS Clusters ==="
aws eks list-clusters \
  --region "$REGION" \
  --profile "$PROFILE" \
  --output table
