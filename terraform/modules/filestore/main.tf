resource "google_filestore_instance" "default" {
  name     = "dify-filestore"
  location = "${var.region}-b"
  tier     = "BASIC_HDD"

  file_shares {
    capacity_gb = 1024
    name        = "share1"
  }

  networks {
    network = var.vpc_network_name
    modes   = ["MODE_IPV4"]
  }
}