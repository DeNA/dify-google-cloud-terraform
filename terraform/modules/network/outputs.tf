output "vpc_network_name" {
  value = google_compute_network.dify_vpc.name
}

output "vpc_subnet_name" {
  value = google_compute_subnetwork.dify_subnet.name

}