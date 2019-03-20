resource "aws_s3_bucket" "api_assets" {
  acl           = "private"
  bucket        = "${var.name}.${var.env}.api-assets"
  force_destroy = true

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://api.${var.domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_policy" "api" {
  bucket = "${aws_s3_bucket.api_assets.id}"
  policy = "${data.template_file.api_assets_origin.rendered}"
}

resource "aws_s3_bucket" "www" {
  acl           = "private"
  bucket        = "${var.name}.${var.env}.www"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "www" {
  bucket = "${aws_s3_bucket.www.id}"
  policy = "${data.template_file.www_origin.rendered}"
}
