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

variable "sandbox_repository_id" {
  type = string
}

variable "vpc_network_name" {
  type = string
}

variable "vpc_subnet_name" {
  type = string
}

variable "plugin_daemon_repository_id" {
  type = string
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

variable "plugin_daemon_storage_name" {
  type = string
}

variable "db_database" {
  type = string
}

variable "db_database_plugin" {
  type = string
}

variable "shared_env_vars" {
  type = map(string)
}
