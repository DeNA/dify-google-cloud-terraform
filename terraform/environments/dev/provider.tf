terraform {
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