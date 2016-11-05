variable "instance_type" {
  description = "Instance type of bastion instance (e.g. t2.micro)"
}

variable "key_pair_name" {
  description = "Name of the Key Pair that can be used to access bastion instance"
}

variable "ami" {
  description = "AMI of bastion instance"
}

variable "security_group_internal_id" {
  description = "Id of security group allowing internal traffic"
}

variable "security_group_ssh_id" {
  description = "Id of security group allowing SSH traffic"
}

variable "bastion_subnet_ids" {
  description = "Comma-separated list of subnets where bastion instance should be deployed"
}
