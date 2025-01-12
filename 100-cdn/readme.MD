
we can block the requests based on more complex conditions by using AWS WAG with CloudFront.

for example, we can block the requests based on IP range

* below setup helps you block requests from unusual users based on geographic location and IP addresses. You can further customize the WAF rules to block requests based on other conditions such as specific headers, query strings, or rate limiting.

```
resource "aws_cloudfront_distribution" "expense" {
  ...
  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["CN", "RU", "IR", "KP"]  # Example countries to block
    }
  }

  web_acl_id = aws_waf_web_acl.example.id

  tags = merge(var.common_tags, var.frontend_tags, {
    Name = "${var.project_name}-${var.environment}-cdn"
  })

  viewer_certificate {
    acm_certificate_arn = data.aws_ssm_parameter.aws_acm_certificate_arn.value
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_waf_web_acl" "example" {
  name        = "example-web-acl"
  metric_name = "exampleWebACL"
  default_action {
    type = "ALLOW"
  }
  rules {
    action {
      type = "BLOCK"
    }
    priority = 1
    rule_id  = aws_waf_ipset.example.id
  }
}

resource "aws_waf_ipset" "example" {
  name        = "example-ipset"
  ip_set_descriptors {
    type  = "IPV4"
    value = "192.0.2.0/24"  # Example IP range to block
  }
}
```

* The geo_restriction block is set to blacklist to block requests from specific countries.
An AWS WAF Web ACL is created to block requests from specific IP addresses.
The Web ACL is associated with the CloudFront distribution.




below setup helps you block requests from unusual users based on geographic location, request rate, and specific request patterns.
```
resource "aws_cloudfront_distribution" "expense" {
  ...
  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["CN", "RU", "IR", "KP"]  # Example countries to block
    }
  }

  web_acl_id = aws_wafv2_web_acl.example.arn

  tags = merge(var.common_tags, var.frontend_tags, {
    Name = "${var.project_name}-${var.environment}-cdn"
  })

  viewer_certificate {
    acm_certificate_arn = data.aws_ssm_parameter.aws_acm_certificate_arn.value
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_wafv2_web_acl" "example" {
  name        = "example-web-acl"
  scope       = "CLOUDFRONT"
  description = "Web ACL to block specific request patterns and rate-limited requests"
  default_action {
    allow {}
  }
  rule {
    name     = "RateLimitRule"
    priority = 1
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 1000  # Requests per 5 minutes
        aggregate_key_type = "IP"
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
}
```
* The geo_restriction block is set to blacklist to block requests from specific countries.
* An AWS WAF Web ACL is created to block requests that exceed a certain rate and requests with specific patterns in the User-Agent header.
* The Web ACL is associated with the CloudFront distribution.



The visibility_config block in an AWS WAF rule configuration specifies how AWS WAF should handle visibility and monitoring for the rule. This block is crucial for enabling logging and metrics, which help you monitor and analyze the behavior of your web application firewall rules.

The aws_wafv2_web_acl_association resource is required to associate an AWS WAF Web ACL with a specific AWS resource, such as a CloudFront distribution, an Application Load Balancer (ALB), or an API Gateway. This association ensures that the rules defined in the Web ACL are applied to the incoming traffic for that resource.

Why Association is Required
Apply Security Rules: By associating a Web ACL with a resource, you ensure that the security rules defined in the Web ACL are enforced on the traffic to that resource. This helps protect your application from common web exploits and attacks.

Centralized Management: AWS WAF allows you to define a set of rules in a Web ACL and apply them to multiple resources. This centralized management simplifies the process of updating and maintaining security rules.

Compliance: Associating a Web ACL with your resources helps you meet security and compliance requirements by ensuring that your resources are protected by a consistent set of security rules.


```
resource "aws_wafv2_web_acl" "example" {
  name        = "example-web-acl"
  scope       = "CLOUDFRONT"
  description = "Web ACL to block specific request patterns and rate-limited requests"
  default_action {
    allow {}
  }
  rule {
    name     = "RateLimitRule"
    priority = 1
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 1000  # Requests per 5 minutes
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      sampled_requests_enabled    = true
      cloudwatch_metrics_enabled  = true
      metric_name                 = "RateLimitRule"
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
      sampled_requests_enabled    = true
      cloudwatch_metrics_enabled  = true
      metric_name                 = "BlockBadBots"
    }
  }
}

resource "aws_cloudfront_distribution" "expense" {
  ...
  web_acl_id = aws_wafv2_web_acl.example.arn
  ...
}

resource "aws_wafv2_web_acl_association" "example" {
  resource_arn = aws_cloudfront_distribution.expense.arn
  web_acl_arn  = aws_wafv2_web_acl.example.arn
}
```

* aws_wafv2_web_acl: Defines the Web ACL with rules to block specific request patterns and rate-limited requests.
* aws_cloudfront_distribution: Defines the CloudFront distribution and associates the Web ACL using the web_acl_id attribute.
* aws_wafv2_web_acl_association: Explicitly associates the Web ACL with the CloudFront distribution using the `resource_arn` and `web_acl_arn` attributes.
By using the `aws_wafv2_web_acl_association` resource, you ensure that the Web ACL is correctly applied to the CloudFront distribution, providing the necessary security protections.
