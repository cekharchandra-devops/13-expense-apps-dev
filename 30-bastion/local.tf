locals {
  instance_name = "${var.project_name}-${var.environmet}"
  bastion_sg = data.aws_ssm_parameter.bastion_sg.value
  public_subnet_id = split(",",data.aws_ssm_parameter.public_subnet_ids.value)[0]
}