#!/bin/bash -ex

cd base-infra

terraform remote config -backend=s3 \
  -backend-config="bucket=603-terraform-remote-state" \
  -backend-config="key=terraform-ecs-autoscale-alb/base-infra.tfstate" \
  -backend-config="region=ap-southeast-2" \
  -backend-config="encrypt=true"

terraform get --update
terraform plan -var-file base-infra.tfvars
terraform apply -var-file base-infra.tfvars

cd ..
