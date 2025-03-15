variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "dify_version" {
  type = string
}

variable "dify_sandbox_version" {
  type = string
}

variable "cloud_run_ingress" {
  type = string
}

variable "nginx_repository_id" {
  type = string
}

variable "web_repository_id" {
  type = string
}

variable "api_repository_id" {
  type = string
}

variable "plugin_daemon_repository_id" {
  type = string
}

variable "sandbox_repository_id" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_port" {
  type = string
}

variable "db_database" {
  type = string
}

variable "db_database_plugin" {
  type = string
}

variable "db_deletion_protection" {
  type = bool
}

variable "storage_type" {
  type = string
}

variable "google_storage_bucket_name" {
  type = string
}

variable "vector_store" {
  type = string
}

variable "indexing_max_segmentation_tokens_length" {
  type = number
}

variable "plugin_daemon_key" {
  type = string
}

variable "plugin_dify_inner_api_key" {
  type = string
}

variable "dify_plugin_daemon_version" {
  type = string
}
