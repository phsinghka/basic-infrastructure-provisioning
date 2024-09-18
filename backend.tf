terraform {
  backend "s3" {
    bucket  = "terraform-backend-phsinghka"
    key     = "state"
    region  = "us-east-2"
    encrypt = true
  }
}
