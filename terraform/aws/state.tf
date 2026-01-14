resource "aws_s3_bucket" "state" {
  bucket_prefix = "state"

  force_destroy = true
}
