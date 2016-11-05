#!/bin/bash -ex
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo Begin: user-data

echo Begin: update and install packages
yum update -y
yum install -y aws-cli jq
echo End: update and install packages

echo Begin: create hello world index.html
mkdir -p /var/www/html
echo '<html><body><h1>Hello world from ${cluster_name}!</h1></body></html>' >> /var/www/html/index.html
echo End: create hello world index.html

echo Begin: start ECS
cluster="${cluster_name}"
echo ECS_CLUSTER=$cluster >> /etc/ecs/ecs.config
start ecs
until $(curl --output /dev/null --silent --head --fail http://localhost:51678/v1/metadata); do
  printf '.'
  sleep 1
done
echo End: start ECS

echo Begin: set up datadog and hello world ECS tasks
dd_task_def="${dd_agent_task_name}"
hello_world_task_def="${hello_world_task_name}"
instance_arn=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .ContainerInstanceArn' | awk -F/ '{print $NF}' )
az=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
region=$${az:0:$${#az} - 1}

echo "
cluster=$cluster
az=$az
region=$region
aws ecs start-task --cluster $cluster --task-definition $dd_task_def --container-instances $instance_arn --region $region
aws ecs start-task --cluster $cluster --task-definition $hello_world_task_def --container-instances $instance_arn --region $region
" >> /etc/rc.local
echo End: set up datadog and hello world ECS tasks

echo End: user-data
