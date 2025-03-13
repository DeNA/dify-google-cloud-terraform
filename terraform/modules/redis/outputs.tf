output "redis_host" {
  value = google_redis_instance.dify_redis.host
}

output "redis_port" {
  value = google_redis_instance.dify_redis.port
}
