resource "aws_cloudfront_origin_access_identity" "api" {
  comment = "Origin access identity for ${var.name} ${var.env} api"
}

resource "aws_cloudfront_distribution" "api" {
  origin {
    domain_name = "${aws_s3_bucket.api.bucket_regional_domain_name}"
    origin_id   = "${var.name}_${var.env}_api"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.api.cloudfront_access_identity_path}"
    }
  }

  enabled = true
  comment = "${var.name} ${var.env} api assets"

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.instance.arn}"
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
    target_origin_id = "${var.name}_${var.env}_api"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
}

resource "aws_cloudfront_origin_access_identity" "web" {
  comment = "Origin access identity for ${var.name} ${var.env} web"
}

resource "aws_cloudfront_distribution" "web" {
  origin {
    domain_name = "${aws_s3_bucket.web.bucket_regional_domain_name}"
    origin_id   = "${var.name}_${var.env}_web"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.web.cloudfront_access_identity_path}"
    }
  }

  aliases = ["${var.route53_zone}"]

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.name} ${var.env} web"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.name}_${var.env}_web"

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
    acm_certificate_arn = "${data.aws_acm_certificate.instance.arn}"
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

resource "aws_cloudfront_origin_access_identity" "web_redirect" {
  comment = "Origin access identity for ${var.name} ${var.env} web redirect"
}

resource "aws_cloudfront_distribution" "web_redirect" {
  origin {
    domain_name = "${aws_s3_bucket.web_redirect.bucket_regional_domain_name}"
    origin_id   = "${var.name}_${var.env}_web_redirect"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.web_redirect.cloudfront_access_identity_path}"
    }
  }

  aliases = ["www.${var.route53_zone}"]

  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.name} ${var.env} web redirect"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.name}_${var.env}_web_redirect"

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
    acm_certificate_arn = "${data.aws_acm_certificate.instance.arn}"
    ssl_support_method  = "sni-only"
  }
}
