locals {
  resource_name = "${var.project_name}-${var.environment}-web-alb"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  subnets = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
}