#!/bin/bash -ex

cd infra

terraform remote config -backend=s3 \
  -backend-config="bucket=603-terraform-remote-state" \
  -backend-config="key=terraform-ecs-autoscale-alb/beta-service.tfstate" \
  -backend-config="region=ap-southeast-2" \
  -backend-config="encrypt=true"

terraform get --update
terraform plan -var-file beta-service.tfvars
terraform apply -var-file beta-service.tfvars

cd ..
