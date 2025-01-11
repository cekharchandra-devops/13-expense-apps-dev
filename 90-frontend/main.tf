module "frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.resource_name
  ami = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [ local.frontend_sg ]
  subnet_id              = local.public_subnet_ids

  tags = merge(
    var.common_tags,
    var.frontend_tags,
    {
      Name = local.resource_name
    }
  )
}

resource "null_resource" "frontend" {
  triggers = {
    instance_id = module.ec2_instance.id
  }
  connection {
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
    host = module.ec2_instance.private_ip
  }
  provisioner "file" {
    source      = "frontend.sh"
    destination = "/tmp/frontend.sh"    
  }
  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/frontend.sh",
        "sudo /tmp/frontend.sh"
    ]
 }

}

resource "aws_ec2_instance_state" "frontend" {
  instance_id = module.ec2_instance.id
  state       = "stopped"
  depends_on = [ null_resource.frontend ]
}

resource "aws_ami_from_instance" "frontend" {
  name               = local.resource_name
  source_instance_id = module.ec2_instance.id
  depends_on = [ aws_ec2_instance_state.frontend ]
  
}

resource "null_resource" "instance_terminate" {
  triggers = {
    instance_id = aws_ami_from_instance.frontend.id
  }
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${module.ec2_instance.id}"
  }
  depends_on = [ aws_ami_from_instance.frontend ]
}

resource "aws_lb_target_group" "frontend" {
  name     = local.resource_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 4
    interval            = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299" 
  }
}

resource "aws_launch_template" "expense" {
  name = local.resource_name

  image_id = aws_ami_from_instance.frontend.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t3.micro"

  vpc_security_group_ids = local.frontend_sg

  tag_specifications {
    resource_type = "instance"

    tags = merge(
        var.common_tags,
        var.frontend_tags,
        {
            Name = local.resource_name
        }
    )
  }

    update_default_version = true

}

resource "aws_autoscaling_group" "expense" {
  name                      = local.resource_name
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = false
  vpc_zone_identifier       = [public_subnet_ids]
  target_group_arns         = [aws_lb_target_group.frontend.arn]
  launch_template {
    id      = aws_launch_template.expense.id
    version = "$Latest"
 }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
  tag {
    key                 = "Name"
    value               = local.resource_name
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_autoscaling_policy" "expense" {
  name = local.resource_name
  autoscaling_group_name = aws_autoscaling_group.expense.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

resource "aws_lb_listener_rule" "expense" {
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
  condition {
    host_header {
        values = ["${var.project_name}-${var.environment}.${var.domain_name}"]
    }
  }
  listener_arn = local.web_alb_arn
}

# resource "aws_autoscaling_policy" "scale_out" {
#   name                   = "scale-out"
#   scaling_adjustment     = 1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.expense.name
# }

# resource "aws_autoscaling_policy" "scale_in" {
#   name                   = "scale-in"
#   scaling_adjustment     = -1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.expense.name
# }

# resource "aws_cloudwatch_metric_alarm" "high_cpu" {
#   alarm_name          = "high-cpu"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 70
#   alarm_description   = "This metric monitors high CPU utilization"
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.expense.name
#   }

#   alarm_actions = [aws_autoscaling_policy.example.arn]
# }

# resource "aws_cloudwatch_metric_alarm" "low_cpu" {
#   alarm_name          = "low-cpu"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 30
#   alarm_description   = "This metric monitors low CPU utilization"
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.expense.name
#   }

#   alarm_actions = [aws_autoscaling_policy.example.arn]
# }