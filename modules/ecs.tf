resource "aws_cloudwatch_log_group" "instance" {
  name = "${var.name}-${var.env}"
}

resource "aws_ecs_cluster" "instance" {
  name = "${var.name}-${var.env}"
}

resource "aws_ecs_task_definition" "api" {
  family                = "${var.name}-${var.env}-api"
  container_definitions = "${data.template_file.api_container_definition.rendered}"

  volume {
    name      = "nginx_conf"
    host_path = "/nginx.conf"
  }
}

resource "aws_ecs_service" "api" {
  name                               = "api"
  cluster                            = "${aws_ecs_cluster.instance.id}"
  task_definition                    = "${aws_ecs_task_definition.api.arn}"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  iam_role                           = "${aws_iam_role.ecs.name}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.instance.arn}"
    container_name   = "nginx"
    container_port   = 80
  }
}