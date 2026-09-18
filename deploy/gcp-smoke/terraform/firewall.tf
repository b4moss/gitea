resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.name_prefix}-allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = local.network_tags

  depends_on = [google_project_service.required]
}

resource "google_compute_firewall" "allow_ssh" {
  count = length(var.allowed_ssh_cidrs) > 0 ? 1 : 0

  name    = "${var.name_prefix}-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_cidrs
  target_tags   = local.network_tags

  depends_on = [google_project_service.required]
}
