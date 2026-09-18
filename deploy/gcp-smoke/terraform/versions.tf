terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Optional: uncomment and set bucket after first local apply if you want shared state.
  # backend "gcs" {
  #   bucket = "YOUR_TF_STATE_BUCKET"
  #   prefix = "gitea/gcp-smoke"
  # }
}
