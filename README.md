# FLARES AGENTS

このリポジトリは、エージェント運用資産（agents / prompts / skills / scripts）のスナップショットをバージョン単位で管理します。

## 最新バージョン

- 最新: `v0.0.11`
- 構成: ルート直下（versioned folder ではなく展開済み）

## インストール方法

まずは npm コマンドでインストールします。

```bash
npm install @flares-llc/agents
```

インストール時、snapshot は現在の作業ディレクトリへ展開されます。

## 重複ファイルがある場合の扱い

既定では `skip` です。既存ファイルがある場合は上書きせず、そのファイルだけスキップします。

選べるポリシー:
- `skip`: 既存ファイルを残してスキップする
- `fail`: 1件でも競合したら停止する
- `overwrite`: 既存ファイルを上書きする
- `backup`: 既存ファイルを `.bak.<timestamp>` として退避してから上書きする

環境変数で指定する例:

```bash
FLARES_AGENTS_ON_CONFLICT=backup npm install @flares-llc/agents
```

CLI で明示実行する例:

```bash
npx @flares-llc/agents --target=. --on-conflict=backup
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
- push停止対策（quick/strict 分離運用）: [docs/qa/push-gate-separation.md](docs/qa/push-gate-separation.md)
- Scripts 構成: [scripts/README.md](scripts/README.md)
- Skills ガイド: [docs/skills/README.md](docs/skills/README.md)
- コミットメッセージ作成ガイド: [.github/instructions/commit-instructions.md](.github/instructions/commit-instructions.md)

## リリース運用ルール（必須）

- リリース作業は必ず `writer` エージェント + `writer-release-management` スキルで実施する
- リリース前に `README.md` / `docs/**` / `AGENTS.md` をブラッシュアップする
- ブラッシュアップ結果は、差分または確認記録として残す

## リリース一覧

- [v0.0.11](https://github.com/flares-llc/agents/releases/tag/v0.0.11)
- [v0.0.10](https://github.com/flares-llc/agents/releases/tag/v0.0.10)
- [v0.0.9](https://github.com/flares-llc/agents/releases/tag/v0.0.9)
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
