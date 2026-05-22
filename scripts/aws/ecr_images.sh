#!/bin/bash

PROFILE="devops-admin"
REGION="us-east-2"
REPO_NAME="devops-demo-app"

echo "ECR images in repository: $REPO_NAME"
echo

aws ecr describe-images \
  --region "$REGION" \
  --profile "$PROFILE" \
  --repository-name "$REPO_NAME" \
  --query "imageDetails[*].[imageTags,imagePushedAt,imageSizeInBytes]" \
  --output table
