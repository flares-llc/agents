# agent-team-snapshots

このリポジトリは、エージェント運用資産（agents / prompts / skills / scripts）のスナップショットをバージョン単位で管理します。

## 最新バージョン

- 最新: `v0.0.3`
- 構成: ルート直下（versioned folder ではなく展開済み）

## v0.0.3 のセットアップ（リポジトリ内完結）

このリポジトリのルートを作業ルートにして実行します。

```bash
npm install
npm run hooks:install
npm run guard:sync:compose
npm run guard:verify
```

必要に応じてフル検証を実行します。

```bash
npm run guard:verify:full
npm run guard:verify:deterministic
```

詳細は以下を参照してください。

- 再現ブートストラップ設計: [docs/qa/github-mcp-reproducible-bootstrap.md](docs/qa/github-mcp-reproducible-bootstrap.md)
- 再現マニフェスト: [docs/qa/repro-manifest.json](docs/qa/repro-manifest.json)
- Scripts 構成: [scripts/README.md](scripts/README.md)
- Skills ガイド: [docs/skills/README.md](docs/skills/README.md)
