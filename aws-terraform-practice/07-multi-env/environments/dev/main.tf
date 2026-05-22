module "app_bucket" {
  source = "../../modules/s3-basic"

  bucket_name = "rain-dev-app-bucket-20260521"
  environment = "dev"
}
