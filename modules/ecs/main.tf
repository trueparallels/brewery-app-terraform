resource "aws_ecs_cluster" "brewery-app-cluster" {
  name = "brewery-app-backend-cluster"
}

resource "aws_ecs_service" "brewery-app-backend-service" {
  name = "brewery-app-backend-service"
  desired_count = 1
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.brewery-app-backend-task.arn
  cluster = aws_ecs_cluster.brewery-app-cluster.arn
  
  load_balancer {
    target_group_arn = aws_alb_target_group.lb_target_group.arn
    container_name = "brewery-app-backend"
    container_port = 80
  }
  
  network_configuration {
    subnets = ["${var.brewery_app_subnet_id}"]
    security_groups = ["${var.brewery_app_sg}"]
    assign_public_ip = true
  }
}

data "template_file" "container_def" {
  template = "${file("${path.module}/tasks/backend.json")}"

  vars = {
    image = "${var.ecr_repo_url}"
    log_group = "${var.cloudwatch_log_group}"
    log_region = "${var.cloudwatch_log_region}"
  }
}

resource "aws_ecs_task_definition" "brewery-app-backend-task" {
  family = "brewery-app-backend-family"
  container_definitions = data.template_file.container_def.rendered
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_iam_policy" "ecs_task_execution_role_policy" {
  name = "ecs_task_execution_role_policy"
  policy = file("${path.module}/policies/allowed_actions_policy.json")
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = file("${path.module}/policies/task_execution_role_policy.json")
}

resource "aws_iam_policy_attachment" "ecs_policy_attachment" {
  name = "ecs_policy_attachment"
  policy_arn = aws_iam_policy.ecs_task_execution_role_policy.arn
  roles = [aws_iam_role.ecs_task_execution_role.name]
}

resource "aws_alb" "load_balancer" {
  name = "brewery-app-backend-lb"
  subnets = ["${var.brewery_app_subnet_id}", "${var.brewery_app_subnet_two_id}"]
  security_groups = ["${var.brewery_app_sg}"]
}

resource "aws_alb_target_group" "lb_target_group" {
  name = "brewery-app-lb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = var.brewery_app_vpc_id
  target_type = "ip"

  health_check {
    path = "/ok"
  }
}

resource "aws_alb_listener" "lb_listener" {
  load_balancer_arn = aws_alb.load_balancer.id
  port = 80
  protocol = "HTTP"
  
  default_action {
    target_group_arn = aws_alb_target_group.lb_target_group.id
    type = "forward"
  }
}
