module "happy_unicorn" {
  source = "./modules/aws-landing-zone"

  github_owner  = var.github_owner
  name          = "happy-unicorn"
  state_backend = <<-HCL
  terraform {
    backend "s3" {
      bucket = "${aws_s3_bucket.state.bucket}"
      region = "${var.aws_region}"
      key    = "state/happy-unicorn/terraform.tfstate"
    }
  }
  HCL
}
