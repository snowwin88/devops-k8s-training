resource "aws_s3_bucket" "demo" {
  bucket = "rain-remote-state-demo-20260521"

  tags = {
    Name      = "rain-remote-state-demo-20260521"
    ManagedBy = "terraform"
    Lab       = "remote-state"
  }
}
