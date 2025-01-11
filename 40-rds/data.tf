
data "aws_ssm_parameter" "db_subnet_ids" {
  name = "/${var.project_name}/${var.environmet}/db_subnet_ids"
}

data "aws_ssm_parameter" "mysql_sg" {
  name  = "/${var.project_name}/${var.environmet}/mysql_sg"
}

data "aws_ssm_parameter" "db_subnet_group_name" {
  name  = "/${var.project_name}/${var.environmet}/db_subnet_group_name"
}