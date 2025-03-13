locals {
  shared_env_vars = {
    "SECRET_KEY"           = var.secret_key
    "LOG_LEVEL"            = "INFO"
    "CONSOLE_WEB_URL"      = ""
    "CONSOLE_API_URL"      = ""
    "SERVICE_API_URL"      = ""
    "APP_WEB_URL"          = ""
    "CHECK_UPDATE_URL"     = "https://updates.dify.ai"
    "OPENAI_API_BASE"      = "https://api.openai.com/v1"
    "FILES_URL"            = ""
    "MIGRATION_ENABLED"    = "true"
    "CELERY_BROKER_URL"    = "redis://${module.redis.redis_host}:${module.redis.redis_port}/1"
    "WEB_API_CORS_ALLOW_ORIGINS" = "*"
    "CONSOLE_CORS_ALLOW_ORIGINS" = "*"
    "DB_USERNAME"          = var.db_username
    "DB_PASSWORD"          = var.db_password
    "DB_HOST"              = module.cloudsql.cloudsql_internal_ip
    "DB_PORT"              = var.db_port
    "DB_DATABASE"          = var.db_database
    "STORAGE_TYPE"         = var.storage_type
    "GOOGLE_STORAGE_BUCKET_NAME" = module.storage.storage_bucket_name
    "GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64" = module.storage.storage_admin_key_base64
    "REDIS_HOST"           = module.redis.redis_host
    "REDIS_PORT"           = module.redis.redis_port
    "VECTOR_STORE"         = var.vector_store
    "PGVECTOR_HOST"        = module.cloudsql.cloudsql_internal_ip
    "PGVECTOR_PORT"        = "5432"
    "PGVECTOR_USER"        = var.db_username
    "PGVECTOR_PASSWORD"    = var.db_password
    "PGVECTOR_DATABASE"    = var.db_database
    "CODE_EXECUTION_ENDPOINT" = google_cloud_run_v2_service.dify_sandbox.uri
    "CODE_EXECUTION_API_KEY" = "dify-sandbox"
    "INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH" = var.indexing_max_segmentation_tokens_length
    "PLUGIN_DAEMON_KEY"    = var.plugin_daemon_key
    "PLUGIN_DIFY_INNER_API_KEY" = var.plugin_dify_inner_api_key
  }
}

module "cloudrun" {
  source = "../../modules/cloudrun"

  project_id                              = var.project_id
  region                                  = var.region
  dify_version                            = var.dify_version
  dify_sandbox_version                    = var.dify_sandbox_version
  cloud_run_ingress                       = var.cloud_run_ingress
  nginx_repository_id                     = var.nginx_repository_id
  web_repository_id                       = var.web_repository_id
  api_repository_id                       = var.api_repository_id
  sandbox_repository_id                   = var.sandbox_repository_id
  vpc_network_name                        = module.network.vpc_network_name
  plugin_daemon_repository_id             = var.plugin_daemon_repository_id
  plugin_daemon_key                       = var.plugin_daemon_key
  plugin_dify_inner_api_key               = var.plugin_dify_inner_api_key
  dify_plugin_daemon_version              = var.dify_plugin_daemon_version
  shared_env_vars                         = local.shared_env_vars
}

module "cloudsql" {
  source = "../../modules/cloudsql"

  project_id  = var.project_id
  region      = var.region
  db_username = var.db_username
  db_password = var.db_password

  vpc_network_name = module.network.vpc_network_name
}

module "redis" {
  source = "../../modules/redis"

  project_id = var.project_id
  region     = var.region

  vpc_network_name = module.network.vpc_network_name
}

module "network" {
  source = "../../modules/network"

  project_id = var.project_id
  region     = var.region
}

module "storage" {
  source = "../../modules/storage"

  project_id                 = var.project_id
  region                     = var.region
  google_storage_bucket_name = var.google_storage_bucket_name
}

module "registry" {
  source = "../../modules/registry"

  project_id            = var.project_id
  region                = var.region
  nginx_repository_id   = var.nginx_repository_id
  web_repository_id     = var.web_repository_id
  api_repository_id     = var.api_repository_id
  sandbox_repository_id = var.sandbox_repository_id
}

locals {
  services = [
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "redis.googleapis.com",
    "vpcaccess.googleapis.com",
    "run.googleapis.com",
    "storage.googleapis.com",
  ]
}

resource "google_project_service" "enabled_services" {
  for_each = toset(local.services)
  project  = var.project_id
  service  = each.value
}
