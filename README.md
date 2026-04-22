# FLARES AGENTS

このリポジトリは、エージェント運用資産（agents / prompts / skills / scripts）のスナップショットをバージョン単位で管理します。

## 最新バージョン

- 最新: `v0.0.8`
- 構成: ルート直下（versioned folder ではなく展開済み）

## インストール方法

まずは npm コマンドでインストールします。

```bash
npm install @flares-llc/agents
```

## 手動セットアップ

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

## リリース運用ルール（必須）

- リリース作業は必ず `writer` エージェント + `writer-release-management` スキルで実施する
- リリース前に `README.md` / `docs/**` / `AGENTS.md` をブラッシュアップする
- ブラッシュアップ結果は、差分または確認記録として残す

## リリース一覧

- [v0.0.8](https://github.com/flares-llc/agents/releases/tag/v0.0.8)
- [v0.0.7](https://github.com/flares-llc/agents/releases/tag/v0.0.7)
- [v0.0.6](https://github.com/flares-llc/agents/releases/tag/v0.0.6)
- [v0.0.5](https://github.com/flares-llc/agents/releases/tag/v0.0.5)
- [v0.0.4](https://github.com/flares-llc/agents/releases/tag/v0.0.4)
- [v0.0.3](https://github.com/flares-llc/agents/releases/tag/v0.0.3)
- [v0.0.2](https://github.com/flares-llc/agents/releases/tag/v0.0.2)

## GitHub Actions で npm 公開する

- ワークフロー: `.github/workflows/publish-npm.yml`
- トリガー:
	- GitHub Release の publish 時
	- `workflow_dispatch` 手動実行
- 必須シークレット:
	- `NPM_TOKEN`（npm publish 権限を持つ token）
- 公開先:
	- npm registry（`https://registry.npmjs.org/`）

運用メモ:
- リリースタグ `vX.Y.Z` と `package.json` の `version` を一致させる（ワークフローで検証）
- リリース前に README/docs/AGENTS のブラッシュアップを必ず実施する
