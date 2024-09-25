terraform {
  required_version = ">=1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.10.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "5.10.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0"
    }
  }

  backend "gcs" {
    bucket = "your-tfstate-bucket" # replace with your bucket name
    prefix = "dify"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}