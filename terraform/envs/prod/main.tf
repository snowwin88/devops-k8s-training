module "demo_app" {
  source = "../../modules/k8s-app"

  environment       = var.environment
  app_name          = var.app_name
  app_env           = var.app_env
  log_level         = var.log_level
  image_repository  = var.image_repository
  image_tag         = var.image_tag
  image_pull_policy = var.image_pull_policy
  replica_count     = var.replica_count
  service_type      = var.service_type
  service_port      = var.service_port
  container_port    = var.container_port
  db_user           = var.db_user
  db_password       = var.db_password
}
