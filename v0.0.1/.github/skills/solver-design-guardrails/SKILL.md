---
name: solver-design-guardrails
description: "Solver が実装前の設計で品質を担保するためのガードレールスキル。Use when: design before fix, plan minimal change, commonize duplicated logic, security/performance review, architecture tradeoff"
---

# Solver Design Guardrails Skill

## Goal
実装前の設計で品質リスクを先に潰し、最小変更で再発防止まで到達する。

## When To Use
- 修正着手前に設計判断が必要なとき
- 複数ファイルにまたがる変更で、共通化可否を判断したいとき
- セキュリティ/パフォーマンス影響を事前評価したいとき

## Core Principles
- 共通化できる限り共通化する。
- 変更箇所は問題解決に必要な最小範囲に留める。
- セキュリティとパフォーマンスを先に評価してから実装する。
- 互換性を壊す変更は避け、必要時は移行手順を用意する。
- エラーメッセージは利用者が次の行動を取れる品質にする。

## Design Checklist
1. 問題定義を固定する。
   - 症状、再現条件、受け入れ条件を1枚で揃える。
2. 重複を探索する。
   - 同一ロジックが3箇所以上なら共通化必須、2箇所なら推奨。
3. 最小変更案を作る。
   - 代替案を2案以上出し、変更量とリスクで比較する。
4. セキュリティを評価する。
   - 認証/認可、入力検証、機密情報露出、権限境界、依存脆弱性を確認する。
5. パフォーマンスを評価する。
   - N+1、不要な全件取得、再レンダリング、過剰I/O、インデックス不足を確認する。
6. 監視とロールバックを設計する。
   - 失敗時の検知方法と切り戻し手順を決める。
7. テスト方針を決める。
   - Unit/Integration/E2E のどこで回帰を防ぐかを明確にする。

## Non-Functional Requirements
- Security: threat model を最低1つ明示し、対策を設計に紐づける。
- Performance: 実装前後で見る指標を決める（例: 応答時間、クエリ数）。
- Reliability: 例外時の挙動と再試行方針を明示する。
- Operability: ログとメトリクスで異常検知できる状態にする。

## Quantitative Gate Baseline
- Security
   - 認可漏れの新規導線を0件にする。
   - 機密情報のログ出力増加を0件にする。
- Performance
   - 主要APIでクエリ回数を増やさない（N+1を0件）。
   - 主要導線の不要API呼び出しを増やさない。
- Testability
   - 受け入れ条件ごとに最低1つの検証手段（Unit/Integration/E2E）を紐づける。
   - 変更起点の回帰ケースを0件取りこぼさない。

## Escalation Trigger
- 上記ゲートを満たせない場合は、実装前に Coordinator へエスカレーションする。
- 設計判断が競合する場合は、代替案とトレードオフを2案以上提示して判断を仰ぐ。

## Design Output Template
```md
## Design Summary
- Problem:
- Scope:
- Non-goals:

## Commonization Plan
- Candidate duplicated logic:
- Shared module decision:
- Why:

## Minimal Change Plan
- Files to change:
- Files not to change:
- Risk:

## Security Review
- Threats:
- Mitigations:

## Performance Review
- Bottlenecks:
- Metrics to verify:

## Test Strategy
- Unit:
- Integration:
- E2E:

## Rollback Plan
- Trigger:
- Steps:
```

## Done Criteria
- 共通化方針、最小変更方針、セキュリティ/パフォーマンス評価が文書化されている。
- 受け入れ条件に対応するテスト戦略が定義されている。
- 実装前に主要リスクとロールバック手順が合意されている。
