resource "google_artifact_registry_repository" "nginx_repo" {
  provider      = google-beta
  project       = var.project_id
  location      = var.region
  repository_id = var.nginx_repository_id
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "api_repo" {
  provider      = google-beta
  project       = var.project_id
  location      = var.region
  repository_id = var.api_repository_id
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "web_repo" {
  provider      = google-beta
  project       = var.project_id
  location      = var.region
  repository_id = var.web_repository_id
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  remote_repository_config {
    docker_repository {
      public_repository = "DOCKER_HUB"
    }
  }
}

resource "google_artifact_registry_repository" "sandbox_repo" {
  provider      = google-beta
  project       = var.project_id
  location      = var.region
  repository_id = var.sandbox_repository_id
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  remote_repository_config {
    docker_repository {
      public_repository = "DOCKER_HUB"
    }
  }
}