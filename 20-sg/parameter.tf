resource "aws_ssm_parameter" "mysql_sg" {
  name  = "/${var.project_name}/${var.environment}/mysql_sg"
  type  = "String"
  value = module.mysql_sg.sg_id
}

resource "aws_ssm_parameter" "backend_sg" {
  name  = "/${var.project_name}/${var.environment}/backend_sg"
  type  = "String"
  value = module.backend_sg.sg_id
}

resource "aws_ssm_parameter" "frontend_sg" {
  name  = "/${var.project_name}/${var.environment}/frontend_sg"
  type  = "String"
  value = module.frontend_sg.sg_id
}

resource "aws_ssm_parameter" "bastion_sg" {
  name  = "/${var.project_name}/${var.environment}/bastion_sg"
  type  = "String"
  value = module.bastion_sg.sg_id
}

resource "aws_ssm_parameter" "ansible_sg" {
  name  = "/${var.project_name}/${var.environment}/ansible_sg"
  type  = "String"
  value = module.ansible_sg.sg_id
}

resource "aws_ssm_parameter" "app_alb_sg" {
  name  = "/${var.project_name}/${var.environment}/app_alb_sg"
  type  = "String"
  value = module.app_alb_sg.sg_id
}

resource "aws_ssm_parameter" "vpn_sg" {
  name  = "/${var.project_name}/${var.environment}/vpn_sg"
  type  = "String"
  value = module.vpn_sg.sg_id
}

resource "aws_ssm_parameter" "web_alb_sg" {
  name  = "/${var.project_name}/${var.environment}/web_alb_sg"
  type  = "String"
  value = module.vpn_sg.web_alb_sg
}