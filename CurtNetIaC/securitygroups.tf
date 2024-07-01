
# ALB Security Group (Traffic Internet -> ALB)
resource "aws_security_group" "aload-balancer" {
  name        = "aload_balancer_security_group"
  description = "Controls access to the ALB"
  vpc_id      = local.vpcid

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nload-balancer" {
  name        = "nload_balancer_security_group"
  description = "Controls access to the NLB for bastions allowing only my home network"
  vpc_id      = local.vpcid

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["213.55.247.153/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance Security group (traffic ALB -> EC2)
resource "aws_security_group" "ec2web" {
  name        = "ec2_security_group"
  description = "Allows inbound access from ALB only and outbound to any"
  vpc_id      = local.vpcid

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.aload-balancer.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "bastion"{
  name        = "bastion22-security-group"
  description = "Allows inbound access from my nlb only on 22 for SSH and internet outbound"
  vpc_id      = local.vpcid
    
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.nload-balancer.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "db" {
    name        = "db_security_group"
    description = "Allows mysql queries from private subnet containing webservers"
    vpc_id      = local.vpcid
    ingress {
      from_port = 3306
      to_port   = 3306
      protocol  = "tcp"
      cidr_blocks = aws_subnet.aws_priv_subnets[*].cidr_block
    }
  }
