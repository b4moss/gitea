variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Region for Artifact Registry (use us-central1 for e2-micro free tier affinity)"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Compute zone for the disposable smoke VM"
  default     = "us-central1-a"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "gitea-smoke"
}

variable "artifact_repo_id" {
  type        = string
  description = "Artifact Registry repository ID"
  default     = "gitea"
}

variable "image_tag" {
  type        = string
  description = "Container image tag to pull from Artifact Registry (e.g. smoke-abc1234)"
}

variable "machine_type" {
  type        = string
  description = "VM machine type"
  default     = "e2-micro"
}

variable "disk_size_gb" {
  type        = number
  description = "Boot disk size in GB"
  default     = 20
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to SSH (empty = do not open TCP/22)"
  default     = []
}

variable "enable_apis" {
  type        = bool
  description = "Enable required Google APIs via terraform"
  default     = true
}
