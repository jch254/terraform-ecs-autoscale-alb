variable "security_group_internal_id" {
  description = "Id of security group allowing internal traffic"
}

variable "security_group_inbound_id" {
  description = "Id of security group allowing inbound traffic"
}

variable "alb_subnet_ids" {
  description = "Comma-separated list of subnets where ALB should be deployed"
}

variable "vpc_id" {
  description = "Id of VPC where ALB will live"
}

variable "acm_arn" {
  description = "ARN of ACM SSL certificate"
}

variable "route53_zone_id" {
  description = "Route 53 Hosted Zone ID"
}

variable "alb_dns_name" {
  description = "DNS name for ALB"
}
