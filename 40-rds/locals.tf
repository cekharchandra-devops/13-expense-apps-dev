locals {
  instance_name = "${var.project_name}-${var.environmet}"
  db_subnet_ids = data.aws_ssm_parameter.db_subnet_ids.value
  mysql_sg = data.aws_ssm_parameter.mysql_sg.value
  db_subnet_group_name = data.aws_ssm_parameter.db_subnet_group_name.value
}