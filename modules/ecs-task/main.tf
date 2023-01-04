############CREATING A ECS CLUSTER#############

module "ecs-cluster" {
  source = "../ecs-cluster"
  namecluster  = var.namecluster
  allowed_cidr_blocks = var.allowed_cidr_blocks
  vpc_id = var.vpc_id
  subnet_id = var.subnet_id
}

# Example for output in module ecs-cluster
output {
  value = module.ecs-cluster.lb_arn
}
resource "aws_ecs_task_definition" "task" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 2048
  container_definitions    = <<DEFINITION
  [
    {
      "name"      : "nginx",
      "image"     : "nginx:1.23.1",
      "cpu"       : 512,
      "memory"    : 2048,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort"      : 80
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "service" {
  name             = "service"
  cluster          = var.namecluster
  task_definition  = aws_ecs_task_definition.task.id
  desired_count    = 3
  platform_version = "LATEST"
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight = 2
    base = 2
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 1
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.sg.id]
    subnets          = var.subnet_id[0]
  }
  load_balancer {
    target_group_arn = "${aws_alb_target_group.group.arn}"
    container_name   = "nginx"
    container_port   = 80
  }  
  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_alb_target_group" "group" {
  name     = "terraform-example-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/"
    port = 80
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = module.ecs-cluster.lb_arn
  port              = "80"
  protocol          = "HTTP"

  depends_on        = [aws_alb_target_group.group] 
  default_action {
    target_group_arn = "${aws_alb_target_group.group.arn}"
    type             = "forward"
  }
}