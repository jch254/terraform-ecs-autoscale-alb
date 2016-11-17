# Terraform-ecs-autoscale-alb

Amazon [EC2 Container Service (ECS)](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/) is a highly scalable, fast, container management service that makes it easy to run, stop, and manage Docker containers on a cluster of EC2 instances (called container instances).

The idea behind ECS is to create a cluster (a group of container instances managed by ECS), define what Docker containers we want to run (with configuration for each container) and ECS will take care of deploying those containers across the cluster, rolling out new versions and integrating with other AWS infrastructure/services.

A task definition is required to run a Docker container on an ECS cluster. A task definition specifies various parameters such as which Docker image(s) to use and the repository in which the image is stored, how much CPU and memory to use for the container, which environment variables should be passed to the container when it starts, which logging driver to use (awslogs, syslog etc.).

---

This repo contains Terraform configuration for an ECS cluster running three services (alpha, beta and charlie) with instance and service autoscaling configured at 80% CPU and memory (min and max autoscaling limits can be configured). The three services are sitting behind an Application Load Balancer (ALB) with path based routing set up.

As far as I could tell the ALB doesn't currently support URL Rewriting so I've had to manually perform this at the application level.

The code for the demo API is in the [/demo-api](../master/demo-api/) directory and is built and hosted on Docker Hub.

[![Dockerhub badge](http://dockeri.co/image/jch254/ecs-demo-api)](https://hub.docker.com/r/jch254/ecs-demo-api)


## Base-infra components:

+ VPC
+ Public and private subnets
+ Internet Gateway
+ NAT Gateways
+ ALB in public subnet with Route53 record
+ ECS cluster
+ ECS container instances in private subnet with autoscaling configured (running Datadog agent and NGINX serving a default index.html for ALB default action on boot)
+ Bastion instance in public subnet (in ASG with a fixed size of one). This only allows SSH access for a specific IP address.

## Service components

- ECS service with autoscaling configured
- ALB listener and target group

## Deploying via Bitbucket Pipelines

Deployment to AWS is automated via Bitbucket Pipelines.

**Before running pipeline for the first time you must:**

1. Enable Bitbucket Pipelines for repository
1. Create an S3 bucket named 'your-terraform-remote-state' for Terraform remote state via console or CLI
1. Create a Bitbucket Pipelines IAM user with the required permissions
1. Set up the following account-level Bitbucket Pipelines environment variables in Bitbucket UI:
    - AWS_ACCESS_KEY_ID = PIPELINES_USER_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY = PIPELINES_USER_SECRET_ACCESS_KEY
1. Set up the following repository-level Bitbucket Pipelines environment variables in Bitbucket UI:
    - TF_VAR_ssh_allowed_ip = YOUR_IP
    - TF_VAR_acm_arn = YOUR_ACM_CERT_ARN
    - TF_VAR_route53_zone_id = YOUR_R53_ZONE_ID
    - TF_VAR_datadog_api_key = YOUR_DATADOG_API_KEY
    - TF_VAR_key_pair_name = YOUR_KEY_PAIR_NAME
    - TF_VAR_bastion_key_pair_name = YOUR_KEY_PAIR_NAME
1. Edit configuration in the .tfvars file in [/base-infra](../master/base-infra/), [/alpha-service](../master/alpha-service/), [/beta-service](../master/beta-service/) and [/charlie-service](../master/charlie-service/) directories with required values.
1. Update deploy.bash file in [/base-infra](../master/base-infra/), [/alpha-service](../master/alpha-service/), [/beta-service](../master/beta-service/) and [/charlie-service] (../master/charlie-service/) directories with your remote state bucket name.
1. Uncomment steps in [/bitbucket-pipelines.yml](../master/bitbucket-pipelines.yml) and commit to repository to trigger the pipeline

Refer to deploy.bash files for manual deployment steps.

- TODO: Add comments throughout infra code
