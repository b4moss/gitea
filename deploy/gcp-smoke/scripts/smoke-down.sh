#!/usr/bin/env bash
# Destroy the disposable smoke VM (keeps Artifact Registry repo by default).
#
#   CONFIRM=1 ./scripts/smoke-down.sh
#   CONFIRM=1 DESTROY_REGISTRY=1 ./scripts/smoke-down.sh
set -euo pipefail

if [[ "${CONFIRM:-0}" != "1" ]]; then
  echo "Refusing to destroy without CONFIRM=1" >&2
  exit 1
fi

TF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../terraform" && pwd)"
cd "${TF_DIR}"

if [[ ! -d .terraform ]]; then
  terraform init -input=false
fi

if [[ "${DESTROY_REGISTRY:-0}" == "1" ]]; then
  terraform destroy -input=false -auto-approve
else
  targets=(
    -target=google_compute_instance.smoke
    -target=google_compute_address.smoke
    -target=google_compute_firewall.allow_http_https
    -target=google_service_account.smoke_vm
    -target=google_artifact_registry_repository_iam_member.smoke_vm_reader
    -target=google_project_iam_member.smoke_vm_log_writer
  )
  if terraform state list 2>/dev/null | grep -q 'google_compute_firewall.allow_ssh'; then
    targets+=(-target='google_compute_firewall.allow_ssh[0]')
  fi
  terraform destroy -input=false -auto-approve "${targets[@]}"
fi

echo "smoke VM destroyed (Artifact Registry retained unless DESTROY_REGISTRY=1)"
