resource "aws_s3_bucket" "data_bucket" {
  bucket        = "gabrielarprado-cardapio-pizzaria"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.data_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action = [
          "s3:GetObject"
        ],
        Resource = ["${aws_s3_bucket.data_bucket.arn}/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.data_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_object" "angular_files" {
  bucket = aws_s3_bucket.data_bucket.id
  key    = "db.json"
  source = "${path.module}/data/db.json"
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.data_bucket.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
  }
}