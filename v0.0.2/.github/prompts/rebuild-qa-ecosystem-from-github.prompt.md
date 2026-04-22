---
mode: "agent"
description: "GitHub MCP 参照で QA エコシステムを再構築する。Use when: bootstrap agents skills prompts from canonical public repository"
---
# GitHub MCP 参照で QA エコシステムを再構築

あなたは再現性重視のセットアップエージェントです。
目的は、公開 GitHub リポジトリを唯一の参照元として、対象リポジトリ内に QA カスタマイズ資産を同型再構築することです。

## 期待成果

- 参照元の canonical 定義を読み取り、対象リポジトリへ再現配置する
- `profile=full` の manifest を前提に `.github/agents`, `.github/skills`, `.github/prompts`, `.github/instructions`, `.github/hooks`, `.vscode/mcp.json`, `AGENTS.md` を同期する
- 同期後に契約検証を実行して fail-closed で結果を返す

## 入力パラメータ

- `sourceRepo`: 既定 `flares-llc/kihoku-apps`
- `sourceRef`: 既定 `main`
- `manifestPath`: 既定 `docs/qa/repro-manifest.json`
- `syncMode`: `apply` または `dry-run`（既定 `apply`）

## 実行手順

1. GitHub MCP 経由で `sourceRepo@sourceRef` の `manifestPath` を取得する。
2. manifest を読み、`targets` を順番に処理する。
3. 各 target について:
   - `sourcePath` の内容を GitHub MCP 経由で取得する。
   - `allowlistRoots` を満たすことを確認する。
   - `syncMode=dry-run` なら差分のみ報告する。
   - `syncMode=apply` なら対象パスへ上書き反映する（不足ディレクトリは作成）。
4. 反映後、以下を実行する。
   - `npm run qa:customizations:validate`
   - `npm run qa:zero-risk:contract`
5. 必要時（利用者が要求した場合）は追加で以下を実行する。
   - `npm run guard:verify:deterministic`
6. 最後に次をまとめて報告する。
   - 同期したファイル一覧
   - 失敗したファイル一覧（あれば原因）
   - 検証コマンドと結果
   - 次アクション（必要な場合のみ）

## 完全性チェック

- manifest の `profile` が `full` でない場合は停止し、理由を報告する
- `.github/agents` に `router.agent.md` と `deployer.agent.md` がない場合は停止する
- `.github/skills` に `solver-frontend-accessibility-validation-audit/SKILL.md` がない場合は停止する
- `.vscode/mcp.json` がない場合は停止する

## 守るべき制約

- allowlist 外のファイルは編集しない。
- 実装コード（`apps/` 配下）へは触れない。
- 取得不能なファイルが `required=true` の場合は fail-closed で停止する。
- 変更は最小差分で行い、無関係な整形はしない。

## 実行例

- `/rebuild-qa-ecosystem-from-github`
- `/rebuild-qa-ecosystem-from-github sourceRepo=flares-llc/kihoku-apps sourceRef=main syncMode=dry-run`
