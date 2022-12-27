resource "aws_ecs_cluster" "cluster" {
  name = var.namecluster
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_security_group" "alb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_alb" "alb" {
  name            = "terraform-example-alb"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = var.subnet_id[0]
}

# resource "aws_alb_listener" "listener_https" {
#   load_balancer_arn = "${aws_alb.alb.arn}"
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "${var.certificate_arn}"
#   default_action {
#     target_group_arn = "${aws_alb_target_group.group.arn}"
#     type             = "forward"
#   }
# }