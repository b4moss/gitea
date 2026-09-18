#!/usr/bin/env bash
# Build the repo Dockerfile and push to Artifact Registry.
# Does NOT run terraform. Review before execute.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../terraform" && pwd)"

if [[ ! -f "${TF_DIR}/terraform.tfvars" ]]; then
  echo "missing ${TF_DIR}/terraform.tfvars — copy terraform.tfvars.example first" >&2
  exit 1
fi

eval "$(python3 - "${TF_DIR}/terraform.tfvars" <<'PY'
import re, sys
path = sys.argv[1]
wanted = {"project_id", "region", "artifact_repo_id"}
text = open(path, encoding="utf-8").read()
vals = {}
for key in wanted:
    m = re.search(rf'^{key}\s*=\s*"([^"]*)"', text, re.M)
    if not m:
        raise SystemExit(f"missing {key} in {path}")
    vals[key] = m.group(1)
for k, v in vals.items():
    print(f'{k}="{v}"')
PY
)"

IMAGE_TAG="${IMAGE_TAG:-smoke-$(git -C "${ROOT_DIR}" rev-parse --short HEAD)}"
AR_BASE="${region}-docker.pkg.dev/${project_id}/${artifact_repo_id}"
IMAGE="${AR_BASE}/gitea:${IMAGE_TAG}"

echo "project=${project_id} region=${region} image=${IMAGE}"

command -v gcloud >/dev/null
command -v docker >/dev/null

gcloud config set project "${project_id}" >/dev/null
gcloud services enable artifactregistry.googleapis.com --project "${project_id}"

if ! gcloud artifacts repositories describe "${artifact_repo_id}" \
  --location="${region}" --project="${project_id}" >/dev/null 2>&1; then
  gcloud artifacts repositories create "${artifact_repo_id}" \
    --repository-format=docker \
    --location="${region}" \
    --project="${project_id}" \
    --description="Gitea container images"
fi

gcloud auth configure-docker "${region}-docker.pkg.dev" --quiet

echo "building ${IMAGE} (this takes a while)..."
docker build \
  --file "${ROOT_DIR}/Dockerfile" \
  --tag "${IMAGE}" \
  "${ROOT_DIR}"

docker push "${IMAGE}"

tmp="$(mktemp)"
if grep -q '^image_tag' "${TF_DIR}/terraform.tfvars"; then
  sed "s/^image_tag.*/image_tag = \"${IMAGE_TAG}\"/" "${TF_DIR}/terraform.tfvars" > "${tmp}"
else
  cat "${TF_DIR}/terraform.tfvars" > "${tmp}"
  printf '\nimage_tag = "%s"\n' "${IMAGE_TAG}" >> "${tmp}"
fi
mv "${tmp}" "${TF_DIR}/terraform.tfvars"

echo
echo "pushed: ${IMAGE}"
echo "updated image_tag in terraform/terraform.tfvars"
echo "next: ./scripts/smoke-up.sh"
