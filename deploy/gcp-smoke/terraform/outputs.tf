output "artifact_registry_repository" {
  description = "Artifact Registry repository resource name"
  value       = google_artifact_registry_repository.gitea.name
}

output "artifact_registry_url" {
  description = "Docker registry host/path prefix for pushes"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_repo_id}"
}

output "image_ref" {
  description = "Full image reference the VM will pull"
  value       = local.image_name
}

output "smoke_external_ip" {
  description = "External IPv4 of the smoke VM"
  value       = google_compute_address.smoke.address
}

output "smoke_https_url" {
  description = "HTTPS URL via sslip.io (Caddy + Let's Encrypt)"
  value       = "https://${google_compute_address.smoke.address}.sslip.io/"
}

output "smoke_vm_name" {
  value = google_compute_instance.smoke.name
}

output "smoke_vm_zone" {
  value = google_compute_instance.smoke.zone
}

output "smoke_service_account" {
  value = google_service_account.smoke_vm.email
}
