terraform {
  backend "s3" {
    bucket         = "cloudporject-terraform-remote-state"
    key            = "dev/threat-composer/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}