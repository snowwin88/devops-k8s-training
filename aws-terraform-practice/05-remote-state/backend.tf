terraform {
  backend "s3" {
    bucket       = "rain-terraform-state-20260521"
    key          = "practice/05-remote-state/terraform.tfstate"
    region       = "us-east-2"
    profile      = "devops-admin"
    encrypt      = true
    use_lockfile = true
  }
}
