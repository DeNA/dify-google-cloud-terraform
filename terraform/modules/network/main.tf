resource "google_compute_network" "dify_vpc" {
  name                    = "dify-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "dify_subnet" {
  name          = "dify-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.dify_vpc.id
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = google_compute_network.dify_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  direction = "EGRESS"
  priority  = 1000

  destination_ranges = ["0.0.0.0/0"]

  target_tags = ["allow-http-https"]
}

resource "google_compute_router" "router" {
  name    = "nat-router"
  network = google_compute_network.dify_vpc.name
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name   = "nat-config"
  router = google_compute_router.router.name
  region = var.region

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

output "vpc_network_name" {
  value = google_compute_network.dify_vpc.name
}

