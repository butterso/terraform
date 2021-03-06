resource "aws_cloudfront_origin_access_identity" "api_assets" {
  comment = "Origin access identity for ${var.name} ${var.env} api assets"
}

resource "aws_cloudfront_distribution" "api_assets" {
  origin {
    domain_name = "${aws_s3_bucket.api_assets.bucket_regional_domain_name}"
    origin_id   = "api-assets.${var.domain_name}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.api_assets.cloudfront_access_identity_path}"
    }
  }

  aliases = ["api-assets.${var.domain_name}"]

  enabled = true
  comment = "${var.name} ${var.env} api assets"

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate_validation.instance.certificate_arn}"
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api-assets.${var.domain_name}"

    forwarded_values {
      query_string = true
      headers      = ["Access-Control-Request-Headers", "Access-Control-Request-Method", "Origin"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
}

resource "aws_cloudfront_origin_access_identity" "www" {
  comment = "Origin access identity for ${var.name} ${var.env} www"
}

resource "aws_cloudfront_distribution" "www" {
  origin {
    domain_name = "${aws_s3_bucket.www.bucket_regional_domain_name}"
    origin_id   = "www.${var.domain_name}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.www.cloudfront_access_identity_path}"
    }
  }

  aliases = ["www.${var.domain_name}"]

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.name} ${var.env} www"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "www.${var.domain_name}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate_validation.instance.certificate_arn}"
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_caching_min_ttl = 60
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 60
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "www_redirect" {
  comment = "Origin access identity for ${var.name} ${var.env} www redirect"
}

resource "aws_cloudfront_distribution" "www_redirect" {
  origin {
    domain_name = "${aws_s3_bucket.www_redirect.website_endpoint}"
    origin_id   = "${var.domain_name}"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  aliases = ["${var.domain_name}"]

  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.name} ${var.env} www redirect"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.domain_name}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate_validation.instance.certificate_arn}"
    ssl_support_method  = "sni-only"
  }
}
