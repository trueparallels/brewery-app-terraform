resource "aws_ecs_cluster" "brewery-app-cluster" {
  name = "brewery-app-backend-cluster"
}

resource "aws_ecs_service" "brewery-app-backend-service" {
  name = "brewery-app-backend-service"
  desired_count = 1
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.brewery-app-backend-task.arn}"
  cluster = "${aws_ecs_cluster.brewery-app-cluster.arn}"
  
  network_configuration {
    subnets = ["${var.brewery_app_subnet_id}"]
  }
}

data "template_file" "container_def" {
  template = "${file("${path.module}/tasks/backend.json")}"

  vars = {
    image = "${var.ecr_repo_url}"
  }
}


resource "aws_ecs_task_definition" "brewery-app-backend-task" {
  family = "brewery-app-backend-family"
  container_definitions = "${data.template_file.container_def.rendered}"
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = "${aws_iam_role.ecs_task_execution_role.arn}"
  task_role_arn = "${aws_iam_role.ecs_task_execution_role.arn}"
}

# data "template_file" "task_execution_role_policy" {
#   template = "${file("${path.module}/policies/task_execution_role_policy.json")}"
# }


resource "aws_iam_policy" "ecs_task_execution_role_policy" {
  policy = "${file("${path.module}/policies/allowed_actions_policy.json")}"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = "${file("${path.module}/policies/task_execution_role_policy.json")}"
}
