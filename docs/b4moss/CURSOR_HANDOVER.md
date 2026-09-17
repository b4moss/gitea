# Cursor 引き渡しメモ（PWA / iOS ズーム）

最終更新: 2026-09-17（JST）  
対象リポジトリ: https://github.com/b4moss/gitea（上流: `go-gitea/gitea`）

## やってほしいこと（独立 PR 推奨）

1. https://github.com/b4moss/gitea/issues/4 — 最小 PWA（`display: standalone`。Service Worker は必要な場合のみ・**キャッシュしない**）。オフラインは対象外。
2. https://github.com/b4moss/gitea/issues/5 — Mobile Safari の入力フォーカスズーム抑制（フォームを **16px 以上**。viewport でズーム無効化は不可）。

## 制約

- 各イシュー本文の Must / Must not / Acceptance Criteria に従うこと
- 上流が削除した「静的資産キャッシュ用 Service Worker」は復活させないこと（参考: go-gitea/gitea#25010）
- **#4 と #5 は混ぜない**（別ブランチ・別 PR）

## 完了条件

- 各イシューのチェックリストを満たす PR（できればイシュー単位で 2 PR）
- PR 説明に、検証手順（特に Android のインストール可否 / iOS Safari のフォーカスズーム）を短く残すこと

## イシュー整理

| 状態 | Issue | 内容 |
|------|-------|------|
| OPEN（正本） | #4 | PWA インストール可能化 |
| OPEN（正本） | #5 | Mobile Safari フォーカスズーム抑制 |
| CLOSED | #2 | #4 へ集約 |
| CLOSED | #3 | #5 へ集約 |

## 背景（短く）

- フォーク目的はスマホでの使いやすさ。まず「ホーム画面に追加して standalone 起動」したい。
- オフライン利用はスコープ外。
- 現行 Gitea は既に `site-manifest.json` を出すが、`display` 等が欠けておりインストール判定が弱い。
- 入力ズームは CSS 側の別問題（16px 未満で Mobile Safari がズームする仕様）。

## 実装時のヒント（非拘束）

- PWA: 第一候補は `routers/web/misc/misc.go` の `SiteManifest` に `display: "standalone"` 等を足す。SW は installability に必要な最小限のみ。
- iOS ズーム: `web_src/css` 等でフォーム部品の font-size を洗い出し、モバイル時に 16px 以上へ底上げ。一括 `!important` は避ける。

詳細は必ず #4 / #5 の本文を正とすること。