#!/bin/bash

# Variables
account_id=$(echo "$1" | cut -d. -f1)
region=$(echo "$1" | cut -d. -f4)
repository="$1"
image_name="$2"
dockerfile_path="$3"
platform="$4"
build_context=$(dirname "$dockerfile_path")

echo "Logging into ECR..."
# Log in to ECR
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $repository

echo "Building the Docker image..."
# Build the Docker image
docker build -t $image_name -f $dockerfile_path $build_context --platform=$platform

echo "Tagging the image with the 'latest' tag..."
# Tag the image with the "latest" tag
docker tag $image_name:latest $repository:latest

echo "Pushing the 'latest' tag to ECR..."
# Push the "latest" tag
docker push $repository:latest

echo "Successfully pushed $image_name with version: $new_version and 'latest' tag"
