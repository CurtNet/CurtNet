resource "aws_kms_key" "aws_kms_key_db" {
  description = "This key is for  ${aws_db_subnet_group.aws_db_subnets.id}"
}
resource "aws_db_instance" "db_instance" {
  db_subnet_group_name = aws_db_subnet_group.aws_db_subnets.name
  count                = length(var.azcount)
  allocated_storage    = 5
  db_name              = "mydb${count.index}"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "curtnetdbusr"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.aws_kms_key_db.key_id
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}
