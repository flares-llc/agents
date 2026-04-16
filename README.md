# agent-team-snapshots

このリポジトリは、エージェント運用向けのスナップショットです。

- Agent 定義（Coordinator / Detector / Solver / Writer / Deployer）
- 品質ゲート・運用ルール
- デプロイ/公開切り替え用スクリプトのテンプレート
- QA 補助スクリプト

## ディレクトリ構成

- `.github/`
  - `agents/`: エージェント定義
  - `instructions/`: 品質ゲートなどの指示
  - `skills/`: 設計・テスト作成向けスキル
- `docs/skills/`
  - スキル利用ガイド
- `scripts/`
  - `commands/`: 手動運用コマンド（deploy / toggle-public）
  - `qa/`: 品質検証・補助スクリプト

## 主なコマンド

実行エントリポイント:

- `./scripts/commands/deploy.sh [frontend|backend|all]`
- `./scripts/commands/toggle-public.sh [public|private]`

後方互換ラッパー:

- `./scripts/deploy.sh`
- `./scripts/toggle-public.sh`

## セットアップ

1. 前提ツールを確認する

- `bash`
- `git`
- `gh` (GitHub CLI)
- `gcloud` (Google Cloud CLI)

2. リポジトリを取得する

```bash
git clone https://github.com/flares-llc/agent-team-snapshots.git
cd agent-team-snapshots
```

3. スクリプト実行権限を確認する

```bash
chmod +x scripts/*.sh scripts/commands/*.sh scripts/qa/*.sh
```

4. テンプレート値を実環境に置き換える

- `scripts/commands/deploy.sh`
  - `<region>`
  - `<project-id>`
  - `<backend-service>`
  - `<frontend-service>`
  - `<backend-source-dir>`
  - `<frontend-source-dir>`
  - `<db-instance>`
  - `<backend-env-file>`
  - `<frontend-cachebust-file>`
- `scripts/commands/toggle-public.sh`
  - `<region>`
  - `<project-id>`
  - `<frontend-service>`
  - `<backend-service>`

5. CLI 認証状態を確認する

```bash
gh auth status
gcloud auth list
gcloud config get-value project
```

6. ドライラン相当で動作確認する

```bash
./scripts/commands/deploy.sh --help || true
./scripts/commands/toggle-public.sh public
./scripts/commands/toggle-public.sh private
```

注記: `toggle-public.sh` は実際に IAM 設定を変更するため、本番環境での実行前に対象プロジェクトとサービス名を必ず確認してください。

## 注意

このスナップショット内のデプロイ/公開切り替えスクリプトはテンプレートです。
`<project-id>` や `<region>` などのプレースホルダーを、実環境の値に置き換えて利用してください。

## 参照

- 運用ガイド: `docs/skills/deployment-and-access.md`
- スクリプト概要: `scripts/README.md`
- 共通ルール: `AGENTS.md`
