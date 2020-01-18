resource "aws_s3_bucket" "bucket" {
  bucket = "${var.lambda_bucket}"
  acl    = "private"
}