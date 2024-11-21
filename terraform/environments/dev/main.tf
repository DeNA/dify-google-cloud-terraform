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
  secret_key                              = var.secret_key
  db_username                             = var.db_username
  db_password                             = var.db_password
  db_host                                 = module.cloudsql.cloudsql_internal_ip
  db_port                                 = var.db_port
  db_database                             = var.db_database
  storage_type                            = var.storage_type
  vector_store                            = var.vector_store
  indexing_max_segmentation_tokens_length = var.indexing_max_segmentation_tokens_length

  vpc_network_name                           = module.network.vpc_network_name
  redis_host                                 = module.redis.redis_host
  redis_port                                 = module.redis.redis_port
  google_storage_service_account_json_base64 = module.storage.storage_admin_key_base64
  google_storage_bucket_name                 = module.storage.storage_bucket_name

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