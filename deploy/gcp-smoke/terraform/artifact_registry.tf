resource "google_artifact_registry_repository" "gitea" {
  location      = var.region
  repository_id = var.artifact_repo_id
  description   = "Gitea container images (smoke / deploy)"
  format        = "DOCKER"

  labels = {
    purpose = "gitea"
    env     = "smoke"
  }

  depends_on = [google_project_service.required]
}
