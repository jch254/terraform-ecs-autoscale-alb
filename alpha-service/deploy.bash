#!/bin/bash -ex

cd alpha-service

terraform remote config -backend=s3 \
  -backend-config="bucket=603-terraform-remote-state" \
  -backend-config="key=terraform-ecs-autoscale-alb/alpha-service.tfstate" \
  -backend-config="region=ap-southeast-2" \
  -backend-config="encrypt=true"

terraform get --update
terraform plan -var-file alpha-service.tfvars
terraform apply -var-file alpha-service.tfvars

cd ..
