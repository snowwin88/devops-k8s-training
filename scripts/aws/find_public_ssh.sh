#!/bin/bash

PROFILE="devops-admin"
REGION="us-east-2"

echo "Security groups allowing SSH from 0.0.0.0/0"
echo

aws ec2 describe-security-groups \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "SecurityGroups[?IpPermissions[?FromPort==\`22\` && ToPort==\`22\` && IpRanges[?CidrIp=='0.0.0.0/0']]].[GroupId,GroupName,VpcId]" \
  --output table
