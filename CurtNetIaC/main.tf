resource "aws_vpc" "curtnet_vpc" {
  cidr_block            = var.vpc_cidr
  enable_dns_hostnames  = true
  enable_dns_support    = true

  tags = {
    name                = "curtnet-vpc"
  }
}

data "aws_availability_zones" "available" {}
locals {
  vpcid           = aws_vpc.curtnet_vpc.id
  #Takes the first X(var.azcount) amount of availability zones
  azs             = slice(data.aws_availability_zones.available.names, 0, var.azcount)
#cidrsubnet(prefix, newbits, netnum) i.e for vpc cidr block 172.27.0.0/16 and 3 AZs Private subnets 172.27.0.0/20, 172.27.16.0/20, 172.27.32.0/20; Public subnets 172.27.100.0/24, 172.27.101.0/24, 172.27.102.0/24
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 100)]
  db_subnets      = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 150)]
  alb_root_account_id = "009996457667" ##### for Paris eu-west-3
}
resource "aws_s3_bucket" "curtnet_s3_bucket" {
  bucket                = "curtnet-s3-bucket"
}
resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_curtnet_alb" {
  bucket = aws_s3_bucket.curtnet_s3_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_alb.json
}
resource "aws_ecr_repository" "app_ecr_repo" {
  name = "app-repo"
}

#############Public, Private and Database subnets #############

resource "aws_subnet" "aws_pub_subnets" {
  count             = length(local.azs)
  availability_zone = local.azs[count.index]
  cidr_block        = local.public_subnets[count.index]
  vpc_id            = local.vpcid
}
resource "aws_subnet" "aws_priv_subnets" {
  count             = length(local.azs)
  availability_zone = local.azs[count.index]
  cidr_block        = local.private_subnets[count.index]
  vpc_id            = local.vpcid
}
resource "aws_subnet" "aws_db_subnets" {
  count             = length(local.azs)
  availability_zone = local.azs[count.index]
  cidr_block        = local.db_subnets[count.index]
  vpc_id            = local.vpcid
}
resource "aws_db_subnet_group" "aws_db_subnets" {
  subnet_ids        = toset(aws_subnet.aws_db_subnets[*].id)
  tags = {
    name = "db-subnets-grp"
  }
}
#############END Public, Private and Database subnets #############
############# Internet Gateway for vpc #############
resource "aws_internet_gateway" "curtnet_igw" {
  vpc_id = local.vpcid
  tags = {
    name = "curtnet-igw"
  }
}
############# NAT Gateway for public subnet #############

resource "aws_eip" "elasticIP" {
  count                     = length(aws_subnet.aws_pub_subnets)
  depends_on                = [aws_internet_gateway.curtnet_igw]
  tags = {
    name                    = "eip-ngw-${count.index}"
  }
}
resource "aws_nat_gateway" "curtnet_ngw_pub" {
  
  count         = length(aws_subnet.aws_pub_subnets)
  subnet_id     = aws_subnet.aws_pub_subnets[count.index].id
  allocation_id = aws_eip.elasticIP[count.index].id
  depends_on    = [aws_eip.elasticIP, aws_subnet.aws_pub_subnets]
  tags = {
    Name        = "curtnet-ngw-${count.index}"
  }
  
}

############# Public, Private, Database Routing Tables #############
resource "aws_route_table" "curtnet_pub_RT"{
  vpc_id = local.vpcid
  tags = {
    name = "curtnet-pub-RT"
}
}
resource "aws_route_table" "curtnet_priv_RT"{
  vpc_id = local.vpcid
  count  = length(aws_subnet.aws_priv_subnets)
  tags = {
    name = "curtnet-pri-RT-${count.index}"
}
}
 resource "aws_route_table" "curtnet_db_RT"{
  vpc_id = local.vpcid
  count = length(aws_subnet.aws_db_subnets)
  tags = {
    name = "curtnet-db-RT-${count.index}"
}
}
#############END Public, Private, Database Routing Tables #############
############# Routes #############
#pub to internet gateway
 resource "aws_route" "public_internet_igw_route"{
  route_table_id         = aws_route_table.curtnet_pub_RT.id
  gateway_id             = aws_internet_gateway.curtnet_igw.id
  destination_cidr_block = "0.0.0.0/0"

 }
resource "aws_route" "private_public_route"{
  count                  = length(aws_subnet.aws_priv_subnets)
  route_table_id         = aws_route_table.curtnet_priv_RT[count.index].id
  nat_gateway_id         = aws_nat_gateway.curtnet_ngw_pub[count.index].id
  destination_cidr_block = "0.0.0.0/0"
}

#Associate tables to subnets
resource "aws_route_table_association" "public_route_association"{
  count          = length(aws_subnet.aws_pub_subnets)
  route_table_id = aws_route_table.curtnet_pub_RT.id
  subnet_id      = aws_subnet.aws_pub_subnets[count.index].id
}
resource "aws_route_table_association" "private_route_association"{
  count          = length(aws_subnet.aws_priv_subnets)
  route_table_id = aws_route_table.curtnet_priv_RT[count.index].id
  subnet_id      = aws_subnet.aws_priv_subnets[count.index].id
}
 resource "aws_route_table_association" "database_route_association"{
   count          = length(aws_subnet.aws_priv_subnets)
   route_table_id = aws_route_table.curtnet_db_RT[count.index].id
   subnet_id      = aws_subnet.aws_db_subnets[count.index].id
 }
#############END Routes #############
############# Key Pairs for EC2 instances #############
  resource "aws_key_pair" "curtnet_kp" {
  key_name   = "${var.ec2_instance_name}_key_pair"
  public_key = file(var.ssh_pubkey_file)
 }
