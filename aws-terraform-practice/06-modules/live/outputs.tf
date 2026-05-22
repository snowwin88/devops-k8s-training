output "logs_bucket_name" {
  value = module.s3_logs.bucket_name
}

output "logs_bucket_arn" {
  value = module.s3_logs.bucket_arn
}
