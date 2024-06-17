variable "region" {
  description = "AWS Region of resources"
  type        = string
  default     = "eu-west-3"
}

variable "availability_zone" {
  description = "Availability zone where the resources reside"
  type        = string
  default     = "eu-west-3a"
}

variable "ami" {
  description = "ID of the Amazon Machine Image (AMI) for the EC2 Instance"
  type        = string
  default     = "ami-0fda19674ff597992"
}

variable "instance_type" {
  description = "the Type of EC2 instance used to create the instance"
  type        = string
  default     = "t2.micro"
}
