variable "vpc_id" {
  description = "Id of VPC where security groups will live"
}

variable "vpc_cidr_block" {
  description = "The source CIDR block to allow traffic from"
}

variable "ssh_allowed_ip" {
  description = "IP address allowed to SSH to bastion instance"
}
