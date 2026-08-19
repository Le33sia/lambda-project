resource "aws_s3_bucket" "compliance_reports" {
  bucket = "my-compliance-reports-bucket-12345"

  tags = {
    Name        = "Compliance Reports Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "compliance_reports_versioning" {
  bucket = aws_s3_bucket.compliance_reports.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "compliance_reports_encryption" {
  bucket = aws_s3_bucket.compliance_reports.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
