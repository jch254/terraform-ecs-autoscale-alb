#!/bin/bash -ex

cd charlie-service

terraform remote config -backend=s3 \
  -backend-config="bucket=603-terraform-remote-state" \
  -backend-config="key=terraform-ecs-autoscale-alb/charlie-service.tfstate" \
  -backend-config="region=ap-southeast-2" \
  -backend-config="encrypt=true"

terraform get --update
terraform plan -var-file charlie-service.tfvars
terraform apply -var-file charlie-service.tfvars

cd ..
