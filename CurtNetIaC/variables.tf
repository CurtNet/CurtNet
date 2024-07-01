variable "region" {
  description = "AWS Region of resources"
  default     = "eu-west-3"
}
variable "vpc_cidr" {
  description = "CIDR Block VPC"
  default     = "172.27.0.0/16"
}
variable "azcount" {
  description = "The amount of AZs to use, this allows expansion for futher redunancy and higher availability, Minimum must be 2 for RDS DB to work"
  default     = "3"
}
variable "autoscale_min" {
  description = "Minimum autoscale (number of EC2)"
  default     = "2"
}
variable "autoscale_max" {
  description = "Maximum autoscale (number of EC2)"
  default     = "4"
}
variable "autoscale_desired" {
  description = "Desired autoscale (number of EC2)"
  default     = "2"
}
variable "ssh_pubkey_file" {
  description = "Path to SSH public key"
  default     = "./ec2_key.pub"
}
variable "health_check_path" {
  description = "Health check path for the default target group"
  default     = "/"
}
variable "amis" {
  description = "Which AMI to spawn depending on region."
  default = {
    eu-west-3 = "ami-0eb375f24fdf647b8"

  }
}
variable "instance_type" {
  default = "t2.micro"
}
variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  default     = "curtnet-web"
}
variable "docker_compose_curtweb" {
  type = string
  default     = <<EOF
services:
   nginx:
     image: curtnet/curtweb-nginx
     ports:
       - "80:80"
     networks:
       - internal
   php:
     image: curtnet/curtweb-php
     networks:
        - internal
networks:
  internal:
    driver: bridge
EOF
}

variable "alb_root_account_id"{
  default = "009996457667" ##### for Paris eu-west-3
}
data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.202*.0-x86_64-gp2"]
  }
}

