resource "aws_cloudfront_distribution" "expense" {
  origin {
    domain_name              = "${var.project_name}-${var.environment}.${var.domain_name}"
    origin_id                = "${var.project_name}-${var.environment}.${var.domain_name}"
    custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true

  aliases = ["${var.project_name}-cdn.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project_name}-${var.environment}.${var.domain_name}"

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/images/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project_name}-${var.environment}.${var.domain_name}"

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/static/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project_name}-${var.environment}.${var.domain_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }


  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags =merge(var.common_tags, var.frontend_tags, {
    Name = "${var.project_name}-${var.environment}-cdn"
  })

  viewer_certificate {
    acm_certificate_arn = data.aws_ssm_parameter.aws_acm_certificate_arn.value
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
   web_acl_id = aws_wafv2_web_acl.expense.arn
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.domain_name #daws81s.online
  records = [
    {
      name    = "expense-cdn" # *.app-dev
      type    = "A"
      alias   = {
        name    = aws_cloudfront_distribution.expense.domain_name
        zone_id = aws_cloudfront_distribution.expense.hosted_zone_id # This belongs CDN internal hosted zone, not ours
      }
      allow_overwrite = true
    }
  ]
}

# 

resource "aws_wafv2_web_acl" "expense" {
  name        = "example-web-acl"
  scope       = "CLOUDFRONT"
  description = "Web ACL to block specific request patterns and rate-limited requests"
  default_action {
    allow {}
  }
    #   Rate-limit US and NL-based clients to 10,000 requests for every 5 minutes.
  rule {
    name     = "RateLimitRule"
    priority = 1
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 10000  # Requests per 5 minutes
        aggregate_key_type = "IP"
        scope_down_statement {
          geo_match_statement {
            country_codes = ["US", "NL"]
          }
        }
      }
    }
    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name = "RateLimitRule"
    }
  }
  rule {
    name     = "BlockBadBots"
    priority = 2
    action {
      block {}
    }
    statement {
      byte_match_statement {
        search_string = "BadBot"
        field_to_match {
          single_header {
            name = "User-Agent"
          }
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
        positional_constraint = "CONTAINS"
      }
    }
    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name = "BlockBadBots"
    }
  }
   visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name = "BlockBadBots"
    }
}

resource "aws_wafv2_web_acl_association" "expense" {
  resource_arn = aws_cloudfront_distribution.expense.arn
  web_acl_arn  = aws_wafv2_web_acl.expense.arn
}