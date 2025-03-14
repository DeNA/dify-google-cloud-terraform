output "storage_admin_key_base64" {
  value = google_service_account_key.storage_admin_key.private_key
}

output "storage_bucket_name" {
  value = google_storage_bucket.dify_storage.name
}

output "plugin_daemon_storage_bucket_name" {
  value = google_storage_bucket.plugin_daemon_storage.name
}