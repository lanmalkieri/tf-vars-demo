variable "local_env_vars" {
  type = "map"

  default = {
    service  = "dotnet"
    username = "steve"
  }
}

variable "global_env_vars" {
  type = "map"

  default = {
    env         = "dev"
    billing_tag = "infra"
  }
}

variable "port_mappings" {
  type = "list"

  default = [
    {
      host_port      = 9000
      container_port = 9000
      protocol       = "tcp"
    },
    {
      host_port      = 80
      container_port = 80
      protocol       = "tcp"
    },
  ]
}

data "template_file" "td" {
  template = "${file("td.tftemplate")}"

  vars {
    #---------------------------------------------------#  
    # This complex regex is due to a bug in TF
    # https://github.com/terraform-providers/terraform-provider-aws/issues/3292
    #---------------------------------------------------#  
    all_env_vars = "${replace(jsonencode(merge(var.local_env_vars, var.global_env_vars)), "/\"([0-9]+\\.?[0-9]*)\"/", "$1")}"

    port_mappings = "${replace(jsonencode(var.port_mappings), "/\"([0-9]+\\.?[0-9]*)\"/", "$1")}"

    name        = "dotnet"
    image       = "docker.ecr.image"
    environment = "dev"
    region      = "us-east-1"
  }
}

output "default" {
  value = "${data.template_file.td.rendered}"
}
