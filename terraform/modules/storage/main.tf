resource "google_storage_bucket" "dify_storage" {
  force_destroy               = false
  location                    = upper(var.region)
  name                        = "${var.project_id}_${var.google_storage_bucket_name}"
  project                     = var.project_id
  public_access_prevention    = "enforced"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
}

resource "google_service_account" "storage_admin" {
  account_id   = "storage-admin-for-dify"
  display_name = "Storage Admin Service Account"
}

resource "google_storage_bucket_iam_member" "storage_admin" {
  bucket = google_storage_bucket.dify_storage.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.storage_admin.email}"
}

resource "google_service_account_key" "storage_admin_key" {
  service_account_id = google_service_account.storage_admin.id
}

output "storage_admin_key_base64" {
  value = google_service_account_key.storage_admin_key.private_key
}

output "storage_bucket_name" {
  value = google_storage_bucket.dify_storage.name
}