resource "aws_s3_bucket" "angular_bucket" {
  bucket        = "gabrielarprado-angular"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.angular_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.angular_bucket.arn}/*"
      }
    ]
  })
}


resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.angular_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.angular_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

  routing_rules = <<EOF
    [{
        "Condition": {
            "KeyPrefixEquals": "index.html"
        },
        "Redirect": {
            "ReplaceKeyPrefixWith": "browser/index.html"
        }
    }]
    EOF
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.angular_bucket.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.angular_bucket.id

  cors_rule {
    allowed_methods = ["GET", "HEAD", "POST", "PUT", "DELETE"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}


resource "aws_s3_object" "angular_files" {
  for_each = fileset("../pizzaria/dist/", "**/*")
  bucket   = aws_s3_bucket.angular_bucket.id
  key      = each.key
  source   = "${path.module}/../pizzaria/dist/${each.key}"

  content_type = lookup(
    {
      "html" = "text/html"
      "css"  = "text/css"
      "js"   = "application/javascript"
      "json" = "application/json"
      "jpg"  = "image/jpeg"
      "png"  = "image/png"
      "svg"  = "image/svg+xml"
  }, regex("\\.([^.]+)$", each.key)[0], "application/octet-stream")

}