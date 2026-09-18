#!/usr/bin/env bash
# Plan (default) or apply the disposable smoke VM via Terraform.
# Review before execute. Requires image_tag already set (see build-and-push.sh).
#
#   ./scripts/smoke-up.sh           # plan only
#   APPLY=1 ./scripts/smoke-up.sh   # apply
set -euo pipefail

TF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../terraform" && pwd)"
cd "${TF_DIR}"

if [[ ! -f terraform.tfvars ]]; then
  echo "missing terraform.tfvars — copy terraform.tfvars.example and set project_id / image_tag" >&2
  exit 1
fi

command -v terraform >/dev/null
command -v gcloud >/dev/null

terraform init -input=false
terraform plan -input=false -out=tfplan

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Plan only. To apply: APPLY=1 $0"
  echo "Plan file: ${TF_DIR}/tfplan"
  exit 0
fi

terraform apply -input=false tfplan
rm -f tfplan

echo
terraform output
echo
echo "Wait 2–5 minutes for Docker pull + Let's Encrypt, then open:"
terraform output -raw smoke_https_url
echo
