#!/usr/bin/env bash
# Destroy the disposable smoke VM (keeps Artifact Registry repo by default).
#
#   ./scripts/smoke-down.sh                  # destroy VM-related resources
#   DESTROY_REGISTRY=1 ./scripts/smoke-down.sh
set -euo pipefail

TF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../terraform" && pwd)"
cd "${TF_DIR}"

if [[ ! -d .terraform ]]; then
  terraform init -input=false
fi

if [[ "${DESTROY_REGISTRY:-0}" == "1" ]]; then
  terraform destroy -input=false -auto-approve
else
  terraform destroy -input=false -auto-approve \
    -target=google_compute_instance.smoke \
    -target=google_compute_address.smoke \
    -target=google_compute_firewall.allow_http_https \
    -target=google_compute_firewall.allow_ssh \
    -target=google_service_account.smoke_vm \
    -target=google_artifact_registry_repository_iam_member.smoke_vm_reader \
    -target=google_project_iam_member.smoke_vm_log_writer
fi

echo "smoke VM destroyed (Artifact Registry retained unless DESTROY_REGISTRY=1)"
