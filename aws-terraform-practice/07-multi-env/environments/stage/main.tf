module "app_bucket" {
  source = "../../modules/s3-basic"

  bucket_name = "rain-stage-app-bucket-20260521"
  environment = "stage"
}
