resource "aws_ssm_parameter" "web_alb" {
  name = "/${var.project_name}/${var.environment}/web_alb_arn"
  type = "String"
  value = aws_lb.web_alb.arn
}