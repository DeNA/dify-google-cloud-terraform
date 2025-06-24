resource "google_service_account" "dify_service_account" {
  account_id   = "dify-service-account"
  display_name = "Dify Service Account"
}

resource "google_project_iam_member" "dify_service_account_role" {
  for_each = toset([
    "roles/run.admin",
    "roles/storage.admin",
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
    service_account       = google_service_account.dify_service_account.email
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
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
      depends_on = ["dify-web", "dify-api", "dify-plugin-daemon"]
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
        name  = "PLUGIN_DAEMON_URL"
        value = "http://127.0.0.1:5002"
      }
      env {
        name  = "ENDPOINT_URL_TEMPLATE"
        value = "http://127.0.0.1/e/{hook_id}"
      }
      env {
        name  = "SENTRY_DSN"
        value = ""
      }
      env {
        name  = "SENTRY_TRACES_SAMPLE_RATE"
        value = 1.0
      }
      env {
        name  = "SENTRY_PROFILES_SAMPLE_RATE"
        value = 1.0
      }
      env {
        name  = "PLUGIN_REMOTE_INSTALL_HOST"
        value = "127.0.0.1"
      }
      env {
        name  = "PLUGIN_REMOTE_INSTALL_PORT"
        value = 5003
      }
      env {
        name  = "PLUGIN_MAX_PACKAGE_SIZE"
        value = 52428800
      }
      env {
        name  = "INNER_API_KEY_FOR_PLUGIN"
        value = var.plugin_dify_inner_api_key
      }
      env {
        name  = "DB_DATABASE"
        value = var.db_database
      }
      dynamic "env" {
        for_each = var.shared_env_vars
        content {
          name  = env.key
          value = env.value
        }
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
      env {
        name  = "SENTRY_DSN"
        value = ""
      }
      env {
        name  = "NEXT_TELEMETRY_DISABLED"
        value = 0
      }
      env {
        name  = "TEXT_GENERATION_TIMEOUT_MS"
        value = 60000
      }
      env {
        name  = "CSP_WHITELIST"
        value = ""
      }
      env {
        name  = "MARKETPLACE_API_URL"
        value = "https://marketplace.dify.ai"
      }
      env {
        name  = "MARKETPLACE_URL"
        value = "https://marketplace.dify.ai"
      }
      env {
        name  = "TOP_K_MAX_VALUE"
        value = ""
      }
      env {
        name  = "INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH"
        value = ""
      }
      env {
        name  = "PM2_INSTANCES"
        value = 2
      }
      # NOTE: Changing PM2_HOME is required for pm2 to work properly on Cloud Run Gen2 environment because of permission issues
      env {
        name  = "PM2_HOME"
        value = "/app/web/.pm2"
      }
      env {
        name  = "LOOP_NODE_MAX_COUNT"
        value = 100
      }
      env {
        name  = "MAX_TOOLS_NUM"
        value = 10
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
    containers {
      name  = "dify-plugin-daemon"
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.plugin_daemon_repository_id}/langgenius/dify-plugin-daemon:${var.dify_plugin_daemon_version}"
      resources {
        limits = {
          cpu    = "1"
          memory = "4Gi"
        }
      }
      env {
        name  = "PORT"
        value = 5003
      }
      dynamic "env" {
        for_each = var.shared_env_vars
        content {
          name  = env.key
          value = env.value
        }
      }
      env {
        name  = "DB_DATABASE"
        value = var.db_database_plugin
      }
      env {
        name  = "SERVER_PORT"
        value = 5002
      }
      env {
        name  = "SERVER_KEY"
        value = var.plugin_daemon_key
      }
      env {
        name  = "MAX_PLUGIN_PACKAGE_SIZE"
        value = 52428800
      }
      env {
        name  = "PPROF_ENABLED"
        value = false
      }
      env {
        name  = "DIFY_INNER_API_URL"
        value = "http://127.0.0.1:5001"
      }
      env {
        name  = "DIFY_INNER_API_KEY"
        value = var.plugin_dify_inner_api_key
      }
      env {
        name  = "PLUGIN_REMOTE_INSTALLING_HOST"
        value = "0.0.0.0"
      }
      env {
        name  = "PLUGIN_REMOTE_INSTALLING_PORT"
        value = 5003
      }
      env {
        name  = "PLUGIN_WORKING_PATH"
        value = "/app/storage/cwd"
      }
      env {
        name  = "FORCE_VERIFYING_SIGNATURE"
        value = true
      }
      env {
        name  = "PYTHON_ENV_INIT_TIMEOUT"
        value = 120
      }
      env {
        name  = "PLUGIN_MAX_EXECUTION_TIMEOUT"
        value = 600
      }
      env {
        name  = "PIP_MIRROR_URL"
        value = ""
      }
      startup_probe {
        timeout_seconds   = 240
        period_seconds    = 240
        failure_threshold = 1
        tcp_socket {
          port = 5003
        }
      }
      volume_mounts {
        name       = "plugin-daemon"
        mount_path = "/app/storage"
      }
    }
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
        name  = "PORT"
        value = 5000
      }
      env {
        name  = "MODE"
        value = "worker"
      }
      env {
        name  = "PLUGIN_DAEMON_URL"
        value = "http://127.0.0.1:5002"
      }
      env {
        name  = "ENDPOINT_URL_TEMPLATE"
        value = "http://127.0.0.1/e/{hook_id}"
      }
      env {
        name  = "SENTRY_DSN"
        value = ""
      }
      env {
        name  = "SENTRY_TRACES_SAMPLE_RATE"
        value = 1.0
      }
      env {
        name  = "SENTRY_PROFILES_SAMPLE_RATE"
        value = 1.0
      }
      env {
        name  = "PLUGIN_MAX_PACKAGE_SIZE"
        value = 52428800
      }
      env {
        name  = "INNER_API_KEY_FOR_PLUGIN"
        value = var.plugin_dify_inner_api_key
      }
      env {
        name  = "DB_DATABASE"
        value = var.db_database
      }
      dynamic "env" {
        for_each = var.shared_env_vars
        content {
          name  = env.key
          value = env.value
        }
      }
      startup_probe {
        http_get {
          path = "/"
          port = 5000
        }
        initial_delay_seconds = 10
        timeout_seconds       = 240
        period_seconds        = 240
        failure_threshold     = 1
      }
    }
    vpc_access {
      network_interfaces {
        network    = var.vpc_network_name
        subnetwork = var.vpc_subnet_name
      }
      egress = "ALL_TRAFFIC"
    }
    scaling {
      min_instance_count = var.min_instance_count
      max_instance_count = var.max_instance_count
    }
    volumes {
      name = "plugin-daemon"
      nfs {
        server    = var.filestore_ip_address
        path      = "/${var.filestore_fileshare_name}"
        read_only = false
      }
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
      network_interfaces {
        network    = var.vpc_network_name
        subnetwork = var.vpc_subnet_name
      }
      egress = "ALL_TRAFFIC"
    }
  }
}
