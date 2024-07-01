resource "aws_lb" "curtnet_alb" {
  count              = length(aws_subnet.aws_pub_subnets)
  name               = "${var.ec2_instance_name}-alb-${count.index}"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.aload-balancer.id]
  subnets            = aws_subnet.aws_pub_subnets[*].id
  access_logs {
    bucket = aws_s3_bucket.curtnet_s3_bucket.id
    prefix = "access-logs-${count.index}"
  }
  connection_logs {
    bucket  = aws_s3_bucket.curtnet_s3_bucket.id
    enabled = true
    prefix  = "connection-logs-${count.index}"
  }
}
resource "aws_lb" "curtnet_nlb" {
  name               = "bastion-nlb"
  load_balancer_type = "network"
  internal           = false
  security_groups    = [aws_security_group.nload-balancer.id]
  subnets            = aws_subnet.aws_pub_subnets[*].id
  access_logs {
    bucket = aws_s3_bucket.curtnet_s3_bucket.id
    prefix = "access-logs-bastion-nlb"
  }
  connection_logs {
    bucket  = aws_s3_bucket.curtnet_s3_bucket.id
    enabled = true
    prefix  = "connection-logs-bastion-nlb"
  }
}
# Target group
resource "aws_alb_target_group" "http-target-group" {
  count    = length(aws_subnet.aws_pub_subnets)
  name     = "${var.ec2_instance_name}-tg-${count.index}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpcid

  health_check {
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 60
    matcher             = "200"
  }
}
resource "aws_alb_target_group" "ssh-target-group" {
  name     = "bastion-tg"
  port     = 22
  protocol = "TCP"
  vpc_id   = local.vpcid

  health_check {
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 60
    matcher             = "200"
  }
}
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  count                  = length(aws_autoscaling_group.ec2-cluster)
  autoscaling_group_name = aws_autoscaling_group.ec2-cluster[count.index].id
  lb_target_group_arn    = aws_alb_target_group.http-target-group[count.index].arn
}
resource "aws_alb_listener" "ec2-alb-http-listener" {
  count             = length(aws_subnet.aws_priv_subnets)
  load_balancer_arn = aws_lb.curtnet_alb[count.index].id
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.http-target-group]

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.http-target-group[count.index].arn
  }
}
resource "aws_lb_listener" "ec2-alb-ssh-listener" {
  load_balancer_arn = aws_lb.curtnet_nlb.id
  port              = "22"
  protocol          = "TCP"
  depends_on        = [aws_alb_target_group.ssh-target-group]

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ssh-target-group.arn
  }
}
resource "aws_lb_target_group_attachment" "sshtobast" {
  count            = length(aws_subnet.aws_priv_subnets)
  target_group_arn = aws_alb_target_group.ssh-target-group.arn
  target_id        = aws_instance.bastion[count.index].id
  port             = 22
}