resource "google_service_account" "smoke_vm" {
  account_id   = "${var.name_prefix}-vm"
  display_name = "Gitea smoke VM"
  depends_on   = [google_project_service.required]
}

resource "google_artifact_registry_repository_iam_member" "smoke_vm_reader" {
  location   = google_artifact_registry_repository.gitea.location
  repository = google_artifact_registry_repository.gitea.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.smoke_vm.email}"
}

# Allow the VM to write serial/console logs and use default logging if needed.
resource "google_project_iam_member" "smoke_vm_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.smoke_vm.email}"
}
