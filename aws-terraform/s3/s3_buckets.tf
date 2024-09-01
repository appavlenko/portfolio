resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-app-bucket"
  acl    = "private"

  logging {
    target_bucket = "log-bucket"
    target_prefix = "log/"
  }

  versioning {
    enabled = true
  }

  tags = {
    Name = "App-Bucket"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-log-bucket"
  acl    = "log-delivery-write"

  tags = {
    Name = "Log-Bucket"
  }
}
