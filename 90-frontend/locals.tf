locals {
  resource_name = "${var.project_name}-${var.environment}-frontend"
  ami_id = data.aws_ami.ami_info.id
  public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
  frontend_sg = data.aws_ssm_parameter.frontend_sg.value
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  web_alb_arn = data.aws_ssm_parameter.web_alb_arn.value
}