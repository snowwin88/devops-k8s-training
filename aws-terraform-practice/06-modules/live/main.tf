module "s3_logs" {
  source = "../modules/s3-basic"

  bucket_name = "rain-module-s3-logs-20260521"
  environment = "dev"
}
