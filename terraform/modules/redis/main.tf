resource "google_redis_instance" "dify_redis" {
  name              = "dify-redis"
  tier              = "STANDARD_HA"
  memory_size_gb    = 1
  region            = var.region
  project           = var.project_id
  redis_version     = "REDIS_6_X"
  reserved_ip_range = "10.0.1.0/29"

  authorized_network = var.vpc_network_name
}

output "redis_host" {
  value = google_redis_instance.dify_redis.host
}

output "redis_port" {
  value = google_redis_instance.dify_redis.port
}
