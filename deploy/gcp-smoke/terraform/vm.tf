resource "google_compute_address" "smoke" {
  name   = "${var.name_prefix}-ip"
  region = var.region

  depends_on = [google_project_service.required]
}

resource "google_compute_instance" "smoke" {
  name         = "${var.name_prefix}-vm"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = local.network_tags

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.disk_size_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.smoke.address
    }
  }

  service_account {
    email  = google_service_account.smoke_vm.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh.tpl", {
    image = local.image_name
  })

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  allow_stopping_for_update = true

  depends_on = [
    google_artifact_registry_repository_iam_member.smoke_vm_reader,
    google_compute_firewall.allow_http_https,
  ]
}
