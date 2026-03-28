#!/bin/bash

set -e  # Exit on error

# ============================================
# Define Docker image and variables
# ============================================

PROJECT_NAME="threat-composer-app"
IMAGE_NAME="threat-composer-app"
IMAGE_TAG="latest"
ECR_REPO_NAME="threat-composer-app"
AWS_REGION="us-east-1"

# ============================================
# STEP 1: Get AWS Account ID
# ============================================
echo "Getting AWS account ID..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Error: Could not get AWS account ID. Make sure AWS CLI is configured."
    exit 1
fi


# ============================================
# STEP 2: Build Docker Image with Build Arguments
# ============================================
echo "Building Docker image..."
docker build \
  --platform linux/amd64 \
  -f docker/Dockerfile \
  --build-arg IMAGE_TAG=${IMAGE_TAG} \
  -t ${IMAGE_NAME}:${IMAGE_TAG} \
  app/

# ============================================
# STEP 3: Check if ECR repository exists, create if it doesn't
# ============================================
echo "Checking if ECR repository exists..."
aws ecr describe-repositories \
    --repository-names "${ECR_REPO_NAME}" \
    --region "${AWS_REGION}" 2>/dev/null || \
{
    echo "Creating repository..."
    aws ecr create-repository \
        --repository-name "${ECR_REPO_NAME}" \
        --region "${AWS_REGION}"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create ECR repository"
        exit 1
    fi
    echo "Repository created successfully!"
}

# ============================================
# STEP 4: Login to AWS ECR
# ============================================
echo "Authenticating Docker to ECR..."
aws ecr get-login-password --region "${AWS_REGION}" | \
  docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

if [ $? -ne 0 ]; then
    echo "Error: Docker login to ECR failed"
    exit 1
fi
echo "Docker authenticated to ECR successfully!"

# ============================================
# STEP 5: Tag Image for ECR
# ============================================
echo "Tagging Docker image for ECR..."
docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"

if [ $? -ne 0 ]; then
    echo "Error: Docker tag failed"
    exit 1
fi
echo "Docker image tagged successfully!"

# Tag as latest as well
docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest"
# ============================================
# STEP 6: Push Image to ECR
# ============================================
echo "Pushing Docker image to ECR..."
docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"


if [ $? -ne 0 ]; then
    echo "Error: Docker push to ECR failed"
    exit 1
fi
echo "Docker image pushed to ECR successfully!"

# Push latest tag as well
echo "Pushing latest tag to ECR..."
docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest"

if [ $? -ne 0 ]; then
    echo "Error: Docker push latest tag failed"
    exit 1
fi
echo "Latest tag pushed to ECR successfully!"

# ============================================
# DONE!
# ============================================
echo ""
echo "========================================"
echo "All operations completed successfully!"
echo "========================================"
echo ""
echo "Image URI: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"