resource "google_service_account" "dify_service_account" {
  account_id   = "dify-service-account"
  display_name = "Dify Service Account"
}

resource "google_project_iam_member" "dify_service_account_role" {
  for_each = toset([
    "roles/run.admin",
  ])
  project = var.project_id
  member  = "serviceAccount:${google_service_account.dify_service_account.email}"
  role    = each.value
}

resource "google_cloud_run_service_iam_binding" "public_service" {
  location = google_cloud_run_v2_service.dify_service.location
  service  = google_cloud_run_v2_service.dify_service.name
  role     = "roles/run.invoker"
  members = [
    "allUsers",
  ]
}

resource "google_cloud_run_service_iam_binding" "public_sanbox" {
  location = google_cloud_run_v2_service.dify_sandbox.location
  service  = google_cloud_run_v2_service.dify_sandbox.name
  role     = "roles/run.invoker"
  members = [
    "allUsers",
  ]
}

resource "google_cloud_run_v2_service" "dify_service" {
  name     = "dify-service"
  location = var.region
  ingress  = var.cloud_run_ingress
  template {
    service_account = google_service_account.dify_service_account.email
    containers {
      name  = "nginx"
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.nginx_repository_id}/dify-nginx:latest"
      resources {
        limits = {
          cpu    = "1"
          memory = "4Gi"
        }
      }
      ports {
        name           = "http1"
        container_port = 80
      }
      depends_on = ["dify-web", "dify-api"]
      startup_probe {
        timeout_seconds   = 240
        period_seconds    = 240
        failure_threshold = 1
        tcp_socket {
          port = 80
        }
      }
    }
    containers {
      name  = "dify-api"
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.api_repository_id}/dify-api:${var.dify_version}"
      resources {
        limits = {
          cpu    = "1"
          memory = "4Gi"
        }
      }
      env {
        name  = "PORT"
        value = 5001
      }
      env {
        name  = "MODE"
        value = "api"
      }
      env {
        name  = "SECRET_KEY"
        value = var.secret_key
      }
      env {
        name  = "LOG_LEVEL"
        value = "INFO"
      }
      env {
        name  = "CONSOLE_WEB_URL"
        value = ""
      }
      env {
        name  = "CONSOLE_API_URL"
        value = ""
      }
      env {
        name  = "SERVICE_API_URL"
        value = ""
      }
      env {
        name  = "APP_WEB_URL"
        value = ""
      }
      env {
        name  = "CHECK_UPDATE_URL"
        value = "https://updates.dify.ai"
      }
      env {
        name  = "OPENAI_API_BASE"
        value = "https://api.openai.com/v1"
      }
      env {
        name  = "FILES_URL"
        value = ""
      }
      env {
        name  = "MIGRATION_ENABLED"
        value = "true"
      }
      env {
        name  = "CELERY_BROKER_URL"
        value = "redis://${var.redis_host}:${var.redis_port}/1"
      }
      env {
        name  = "WEB_API_CORS_ALLOW_ORIGINS"
        value = "*"
      }
      env {
        name  = "CONSOLE_CORS_ALLOW_ORIGINS"
        value = "*"
      }
      env {
        name  = "DB_USERNAME"
        value = var.db_username
      }
      env {
        name  = "DB_PASSWORD"
        value = var.db_password
      }
      env {
        name  = "DB_HOST"
        value = var.db_host
      }
      env {
        name  = "DB_PORT"
        value = var.db_port
      }
      env {
        name  = "DB_DATABASE"
        value = var.db_database
      }
      env {
        name  = "STORAGE_TYPE"
        value = var.storage_type
      }
      env {
        name  = "GOOGLE_STORAGE_BUCKET_NAME"
        value = var.google_storage_bucket_name
      }
      env {
        name  = "GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64"
        value = var.google_storage_service_account_json_base64
      }
      env {
        name  = "REDIS_HOST"
        value = var.redis_host
      }
      env {
        name  = "REDIS_PORT"
        value = var.redis_port
      }
      env {
        name  = "VECTOR_STORE"
        value = var.vector_store
      }
      env {
        name  = "PGVECTOR_HOST"
        value = var.db_host
      }
      env {
        name  = "PGVECTOR_PORT"
        value = "5432"
      }
      env {
        name  = "PGVECTOR_USER"
        value = var.db_username
      }
      env {
        name  = "PGVECTOR_PASSWORD"
        value = var.db_password
      }
      env {
        name  = "PGVECTOR_DATABASE"
        value = var.db_database
      }
      env {
        name  = "CODE_EXECUTION_ENDPOINT"
        value = google_cloud_run_v2_service.dify_sandbox.uri
      }
      env {
        name  = "CODE_EXECUTION_API_KEY"
        value = "dify-sandbox"
      }
      env {
        name  = "INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH"
        value = var.indexing_max_segmentation_tokens_length
      }
      startup_probe {
        timeout_seconds   = 240
        period_seconds    = 240
        failure_threshold = 1
        tcp_socket {
          port = 5001
        }
      }
    }
    containers {
      name  = "dify-web"
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.web_repository_id}/langgenius/dify-web:${var.dify_version}"
      resources {
        limits = {
          cpu    = "1"
          memory = "4Gi"
        }
      }
      env {
        name  = "PORT"
        value = 3000
      }
      env {
        name  = "CONSOLE_API_URL"
        value = ""
      }
      env {
        name  = "APP_API_URL"
        value = ""
      }
      startup_probe {
        timeout_seconds   = 240
        period_seconds    = 240
        failure_threshold = 1
        tcp_socket {
          port = 3000
        }
      }
    }
    vpc_access {
      connector = "projects/${var.project_id}/locations/${var.region}/connectors/${google_vpc_access_connector.connector.name}"
      egress    = "ALL_TRAFFIC"
    }
    scaling {
      min_instance_count = 1
      max_instance_count = 5
    }
  }
}

resource "google_cloud_run_v2_service" "dify_worker" {
  name     = "dify-worker"
  location = var.region

  template {
    containers {
      name  = "dify-worker"
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.api_repository_id}/dify-api:${var.dify_version}"
      resources {
        limits = {
          cpu    = "1"
          memory = "4Gi"
        }
      }
      env {
        name  = "MODE"
        value = "worker"
      }
      env {
        name  = "SECRET_KEY"
        value = var.secret_key
      }
      env {
        name  = "LOG_LEVEL"
        value = "INFO"
      }
      env {
        name  = "CONSOLE_WEB_URL"
        value = ""
      }
      env {
        name  = "CONSOLE_API_URL"
        value = ""
      }
      env {
        name  = "SERVICE_API_URL"
        value = ""
      }
      env {
        name  = "APP_WEB_URL"
        value = ""
      }
      env {
        name  = "CHECK_UPDATE_URL"
        value = "https://updates.dify.ai"
      }
      env {
        name  = "OPENAI_API_BASE"
        value = "https://api.openai.com/v1"
      }
      env {
        name  = "FILES_URL"
        value = ""
      }
      env {
        name  = "MIGRATION_ENABLED"
        value = "true"
      }
      env {
        name  = "CELERY_BROKER_URL"
        value = "redis://${var.redis_host}:${var.redis_port}/1"
      }
      env {
        name  = "WEB_API_CORS_ALLOW_ORIGINS"
        value = "*"
      }
      env {
        name  = "CONSOLE_CORS_ALLOW_ORIGINS"
        value = "*"
      }
      env {
        name  = "DB_USERNAME"
        value = var.db_username
      }
      env {
        name  = "DB_PASSWORD"
        value = var.db_password
      }
      env {
        name  = "DB_HOST"
        value = var.db_host
      }
      env {
        name  = "DB_PORT"
        value = var.db_port
      }
      env {
        name  = "DB_DATABASE"
        value = var.db_database
      }
      env {
        name  = "STORAGE_TYPE"
        value = var.storage_type
      }
      env {
        name  = "GOOGLE_STORAGE_BUCKET_NAME"
        value = var.google_storage_bucket_name
      }
      env {
        name  = "GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64"
        value = var.google_storage_service_account_json_base64
      }
      env {
        name  = "REDIS_HOST"
        value = var.redis_host
      }
      env {
        name  = "REDIS_PORT"
        value = var.redis_port
      }
      env {
        name  = "VECTOR_STORE"
        value = var.vector_store
      }
      env {
        name  = "PGVECTOR_HOST"
        value = var.db_host
      }
      env {
        name  = "PGVECTOR_PORT"
        value = "5432"
      }
      env {
        name  = "PGVECTOR_USER"
        value = var.db_username
      }
      env {
        name  = "PGVECTOR_PASSWORD"
        value = var.db_password
      }
      env {
        name  = "PGVECTOR_DATABASE"
        value = var.db_database
      }
      env {
        name  = "CODE_EXECUTION_ENDPOINT"
        value = google_cloud_run_v2_service.dify_sandbox.uri
      }
      env {
        name  = "CODE_EXECUTION_API_KEY"
        value = "dify-sandbox"
      }
      env {
        name  = "INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH"
        value = var.indexing_max_segmentation_tokens_length
      }
      startup_probe {
        http_get {
          path = "/"
          port = 5001
        }
        initial_delay_seconds = 10
        timeout_seconds       = 240
        period_seconds        = 240
        failure_threshold     = 1
      }
    }
    vpc_access {
      connector = "projects/${var.project_id}/locations/${var.region}/connectors/${google_vpc_access_connector.connector.name}"
      egress    = "ALL_TRAFFIC"
    }
    scaling {
      min_instance_count = 1
      max_instance_count = 5
    }
  }
}

resource "google_cloud_run_v2_service" "dify_sandbox" {
  name     = "dify-sandbox"
  location = var.region

  template {
    containers {
      name  = "dify-sandbox"
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.sandbox_repository_id}/langgenius/dify-sandbox:${var.dify_sandbox_version}"
      resources {
        limits = {
          cpu    = "1"
          memory = "4Gi"
        }
      }
      ports {
        name           = "http1"
        container_port = 8194
      }
      env {
        name  = "API_KEY"
        value = "dify-sandbox"
      }
      env {
        name  = "GIN_MODE"
        value = "release"
      }
      env {
        name  = "WORKER_TIMEOUT"
        value = "15"
      }
      env {
        name  = "ENABLE_NETWORK"
        value = "true"
      }
      env {
        name  = "SANDBOX_PORT"
        value = 8194
      }
    }
    vpc_access {
      connector = "projects/${var.project_id}/locations/${var.region}/connectors/${google_vpc_access_connector.connector.name}"
      egress    = "ALL_TRAFFIC"
    }
  }
}

resource "google_vpc_access_connector" "connector" {
  name          = "cloud-run-connector"
  region        = var.region
  min_instances = 2
  max_instances = 5
  network       = var.vpc_network_name
  ip_cidr_range = "10.8.0.0/28"
}

output "dify_service_name" {
  value = google_cloud_run_v2_service.dify_service.name
}