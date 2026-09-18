# GCP smoke environment (Artifact Registry + disposable e2-micro)

使い捨てスモーク用の最小構成です。**このディレクトリのスクリプト / `terraform apply` は、レビュー承認後に手動実行してください。**

## 構成

1. **Artifact Registry**（Docker）に Gitea イメージを push
2. **e2-micro** VM を 1 台作成（Docker で Gitea + Caddy）
3. 外部 IP + **HTTPS**（Caddy + Let’s Encrypt、ホストは `${ip}.sslip.io`）

```text
[local/CI] docker build → Artifact Registry
                              ↓ pull
                         e2-micro (Docker)
                         Caddy :443 → Gitea :3000
                         https://<EXTERNAL_IP>.sslip.io
```

## 前提

- `gcloud` / `terraform` (>= 1.5) / `docker`（buildx）
- GCP プロジェクトで課金有効
- 実行者に Artifact Registry / Compute Admin 相当の権限
- 無料枠の e2-micro を使う場合は **zone を `us-central1-*` / `us-west1-*` / `us-east1-*` のいずれか**に（デフォルトは `us-central1-a`）

## 使い方（レビュー後）

```bash
cd deploy/gcp-smoke
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# 既定の project_id は b4m-backyard。region / image_tag など必要なら編集

# 1) イメージをビルドして AR へ push（リポジトリルート前提・時間がかかる）
./scripts/build-and-push.sh

# 2) Terraform plan（デフォルトは apply しない）
./scripts/smoke-up.sh

# 3) 問題なければ apply
APPLY=1 ./scripts/smoke-up.sh

# 4) 出力 URL でスモーク（起動・証明書取得まで数分待つ）
# terraform -chdir=terraform output -raw smoke_https_url

# 5) 破棄（AR リポジトリは残す）
CONFIRM=1 ./scripts/smoke-down.sh
```

**このエージェント実行では `terraform apply` / `build-and-push` / `gcloud` による実デプロイは行っていません。**

## 変数

| 名前 | 説明 |
|------|------|
| `project_id` | GCP プロジェクト |
| `region` | AR / リソースのリージョン（既定 `us-central1`） |
| `zone` | VM ゾーン（既定 `us-central1-a`） |
| `artifact_repo_id` | AR リポジトリ ID（既定 `gitea`） |
| `image_tag` | pull するタグ（`build-and-push.sh` が出力） |
| `allowed_ssh_cidrs` | SSH 許可 CIDR（空なら SSH FW を作らない） |

## 注意

- スモーク専用。データ永続化・バックアップなし（boot disk のみ）
- Let’s Encrypt は HTTP-01（80/443 開放が必要）。証明書取得まで起動後数分かかることがある
- PWA / Mobile Safari 確認は出力の `smoke_https_url` を実機で開く
- `asia-northeast1` に置くと e2-micro 無料枠対象外になる
- 本リポの本番配布先決定（Artifact Registry）に沿った検証経路であり、本家 upstream 向け変更ではない
