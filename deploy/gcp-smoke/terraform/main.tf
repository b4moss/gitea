locals {
  network_tags = ["${var.name_prefix}-vm"]
  image_name   = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_repo_id}/gitea:${var.image_tag}"
}

resource "google_project_service" "required" {
  for_each = var.enable_apis ? toset([
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
  ]) : toset([])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}
