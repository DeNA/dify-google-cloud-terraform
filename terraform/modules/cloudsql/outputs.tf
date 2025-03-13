output "cloudsql_internal_ip" {
  value = google_sql_database_instance.postgres_instance.private_ip_address
}
