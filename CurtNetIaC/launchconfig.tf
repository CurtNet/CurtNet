resource "aws_instance" "bastion" {
  count                       = length(aws_subnet.aws_pub_subnets)
  ami                         = lookup(var.amis, var.region)
  instance_type               = "${var.instance_type}"
  key_name                    = aws_key_pair.curtnet_kp.key_name
  iam_instance_profile        = aws_iam_instance_profile.session-manager.id
  associate_public_ip_address = false
  security_groups            = [aws_security_group.ec2.id]
  subnet_id                   = aws_subnet.aws_priv_subnets[count.index].id
  tags = {
    Name = "bastion"
  }
}
resource "aws_launch_configuration" "ec2" {
  name                        = "${var.ec2_instance_name}-instances-lc"
  image_id                    = lookup(var.amis, var.region)
  instance_type               = "${var.instance_type}"
  security_groups             = [aws_security_group.ec2.id]
  key_name                    = aws_key_pair.curtnet_kp.key_name
  iam_instance_profile        = aws_iam_instance_profile.session-manager.id
  associate_public_ip_address = false
  user_data = <<-EOL
  #!/bin/bash -xe
  sudo yum update -y
  sudo yum -y install docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  sudo chmod 666 /var/run/docker.sock
  docker pull nginx
  docker tag nginx my-nginx
  docker run --rm --name nginx-server -d -p 80:80 -t my-nginx
  echo "Hello World!! You are connected to ${var.ec2_instance_name}" | sudo tee /usr/share/nginx/html/index.html
  EOL
  depends_on = [aws_nat_gateway.curtnet_ngw_pub]
}
resource "aws_autoscaling_group" "ec2-cluster" {
  count                = length(aws_subnet.aws_priv_subnets)
  name                 = "${var.ec2_instance_name}_auto_scaling_group_${count.index}"
  min_size             = var.autoscale_min
  max_size             = var.autoscale_max
  desired_capacity     = var.autoscale_desired
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.ec2.name
  vpc_zone_identifier  = [aws_subnet.aws_priv_subnets[count.index].id]
  target_group_arns    = [aws_alb_target_group.http-target-group[count.index].arn]
}
