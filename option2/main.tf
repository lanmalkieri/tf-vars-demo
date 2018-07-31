provider "aws" {
  profile = "stobie"
  region  = "us-east-1"
}

variable "name" {
  default = "test"
}

variable "environment" {
  default = "dev"
}

variable "env_vars" {
  type = "list"

  default = [
    {
      environment = "dev"
    },
    {
      service = "dotnet"
    },
    {
      test1 = 0
    },
  ]
}

data "template_file" "data_json" {
  template = "${file("${path.module}/data.json.tmpl")}"
  count    = "${length(var.env_vars)}"

  vars {
    key   = "${element(keys(var.env_vars[count.index]), 0)}"
    value = "${element(values(var.env_vars[count.index]), 0)}"
  }
}

data "template_file" "service_json" {
  template = "${file("${path.module}/service.json.tmpl")}"

  vars {
    value       = "${join(",", data.template_file.data_json.*.rendered)}"
    name        = "dotnet"
    environment = "dev"
    region      = "us-east-1"
  }
}

/* resource "aws_ecs_task_definition" "ecs_task_definition" { */
/*   family                   = "${var.name}-${var.environment}" */
/*   container_definitions    = "${data.template_file.service_json.rendered}" */
/*   requires_compatibilities = ["EC2"] */
/*   cpu                      = 1024 */
/*   memory                   = 1024 */
/*   network_mode             = "awsvpc" */
/* } */

output "json" {
  value = "${data.template_file.service_json.rendered}"
}
