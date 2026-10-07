# b4moss/gitea

[Gitea](https://github.com/go-gitea/gitea) の b4moss フォークです。継続利用とローカル改善のために維持しています。

上流の機能・導入手順・ドキュメントなどは公式リポジトリを参照してください。

- 上流リポジトリ: [go-gitea/gitea](https://github.com/go-gitea/gitea)
- 公式 README: [README.md](https://github.com/go-gitea/gitea/blob/main/README.md)

b4moss が継続利用のために維持しているサードパーティフォークは、現時点で本リポジトリ（`b4moss/gitea`）と [`b4moss/cells`](https://github.com/b4moss/cells) の 2 つです。

## バージョニング方針

b4moss リリースのタグ形式は次のとおりです。

```text
{original_version}-b4m{our_version}
```

例（形式のみ。実在するタグではありません）: `1.22.0-b4m1`

| 部分 | 意味 |
| --- | --- |
| `{original_version}` | ベースにした上流バージョン |
| `{our_version}` | このフォーク系列における b4moss 独自の単調増加カウンタ |

`{our_version}` は SemVer ではありません。`major.minor.patch` 形式を要求しません。

### ブランチとタグ

- **追従ブランチ**: 上流ベースラインを追跡するためのブランチ（リリース印ではない）
- **リリースタグ**: b4moss リリースを示すタグ（上記の `{original_version}-b4m{our_version}` 形式を目標とする）

追従用ブランチとリリース用タグは役割を分けて扱います。

### 移行状況

本リポジトリは、まだ上記の `{original}-b4m{our}` タグ付けへ完全移行していません。上流の大きな更新があったため、整合は慎重・段階的に進めます。現存タグは新方針と一致しない場合があります。既存の git 履歴やタグは書き換えません。
