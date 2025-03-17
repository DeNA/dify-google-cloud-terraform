output "filestore_ip_address" {
  value = google_filestore_instance.default.networks[0].ip_addresses[0]
}

output "filestore_fileshare_name" {
  value = google_filestore_instance.default.file_shares[0].name
}