output "vpc_id" {
  description = "vpc id"
  value = aws_vpc.curtnet_vpc.id
}
output "publicIP" {
  value = local.public_subnets
}
output "privateIP" {
  value = local.private_subnets
}
output "databaseIP" {
  value = local.db_subnets
}
output "publicSubnets_ids" {
  description = "publicSubnets IDs"
  value = aws_subnet.aws_pub_subnets[*].id
}
output "privateSubnets_ids" {
  description = "privateSubnets IDs"
  value = aws_subnet.aws_priv_subnets[*].id
}
output "databaseSubnets_ids" {
  description = "databaseSubnets IDs"
  value = aws_subnet.aws_db_subnets[*].id
}
output "IGW_id" {
  description = "internet gateway id"
  value = aws_internet_gateway.curtnet_igw.id
}
output "pubroutetable_id" {
  description = "Public route table id"
  value = aws_route_table.curtnet_pub_RT[*].id
}
output "priroutetable_id" {
  description = "Private route table id"
  value = aws_route_table.curtnet_priv_RT[*].id
}
output "dbroutetable_id" {
  description = "db route table id"
  value = aws_route_table.curtnet_db_RT[*].id
}
output "alb_dns" {
  value = aws_lb.curtnet_alb[*].dns_name
}
output "alb_zone" {
  value = aws_lb.curtnet_alb[*].zone_id
}
output "azsSel" {
  value = local.azs
}
