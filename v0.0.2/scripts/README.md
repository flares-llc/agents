# Scripts Ecosystem (Snapshot)

この保存版は `scripts` を用途別に分離した構成で保持します。

## Structure
- `scripts/commands/`
  - 手動運用コマンド（deploy / access toggle）
- `scripts/qa/`
  - 品質ゲート・検証・自動修復系

## Entry Points
- `./scripts/commands/deploy.sh [frontend|backend|all]`
- `./scripts/commands/toggle-public.sh [public|private]`

## Notes
- `scripts/deploy.sh` と `scripts/toggle-public.sh` は後方互換ラッパーです。
- 保存版の `scripts/commands/` 配下はテンプレート用途として、環境固有値を差し替えて利用します。
