resource "aws_route53_record" "publicapi" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "publicapi.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.publicapi.domain_name
    zone_id                = aws_cloudfront_distribution.publicapi.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_cloudfront_distribution" "publicapi" {
  depends_on = [
    aws_acm_certificate.cert,
    aws_acm_certificate_validation.cert,
  ]

  enabled             = true
  wait_for_deployment = false
  comment             = "${var.environment}-publicapi"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
  }

  aliases = ["publicapi.${var.domain_name}"]

  default_cache_behavior {
    target_origin_id       = "paas"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = 0
    max_ttl                = 0
    default_ttl            = 0

    forwarded_values {
      headers      = ["Host", "Origin", "Authorization"]
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  origin {
    origin_id   = "paas"
    domain_name = var.paas_domain

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

  web_acl_id = aws_wafv2_web_acl.publicapi.id
}

resource "aws_wafv2_web_acl" "publicapi" {
  provider    = aws.us
  name        = "publicapi-${var.environment}"
  description = "Publicapi ACL ${var.environment}"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 0

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        excluded_rule {
          name = "GenericRFI_BODY"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesLinuxRuleSet"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "publicapi-AclMetrics"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "publicapi" {
  log_destination_configs = [module.waf_logging.kinesis_stream_id]
  resource_arn            = aws_wafv2_web_acl.publicapi.arn
  redacted_fields {
    single_header {
      name = "cookie"
    }
  }
}
