module "web_alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "web-alb"
  vpc_id  = local.vpc_id
  subnets = local.subnets

  enable_deletion_protection = false

  tags = merge(
    var.common_tags,
    var.web_alb_tags,
    {
      Name = local.resource_name
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Fixed response from WEB ALB"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = module.web_alb.arn
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_ssm_parameter.aws_acm_certificate_arn.value
  alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = "Fixed response from WEB ALB using HTTPS"
      status_code  = "200"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.domain_name

  records = [
    {
      name    = "${var.project_name}-${var.environment}"
      type    = "CNAME"
      alias   = {
        name    = module.web_alb.dns_name
        zone_id = module.web_alb_sg.zone_id
      }
    }
  ]

}