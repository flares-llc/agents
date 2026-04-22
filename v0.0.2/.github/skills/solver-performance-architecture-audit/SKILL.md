---
name: solver-performance-architecture-audit
description: "Solver が性能とアーキテクチャ健全性を監査し、ボトルネックと境界劣化を同一サイクルで解消するためのスキル。Use when: API/DB boundary changes, query additions, frontend data flow changes, module boundary refactors"
---

# Solver Performance Architecture Audit Skill

## Goal
性能劣化とアーキテクチャ劣化を早期検知し、最小変更で改善して再発防止まで完了する。

## When To Use
- API/DB境界をまたぐ変更がある
- クエリ追加やデータ取得量に影響する変更がある
- UI導線やデータフェッチ戦略を変更する
- 共通化・モジュール境界の設計判断が必要

## Core Principles
- まず計測し、次に最小修正する。
- N+1 と過剰通信を新規導入しない。
- モジュール境界の一貫性を壊さない。

## Audit Checklist
1. DB/API
   - N+1、不要全件取得、過剰JOIN、インデックス不足の有無。
2. Frontend Runtime
   - 不要再レンダリング、重複fetch、過剰payloadの有無。
3. Architecture
   - 重複ロジック、依存方向逆転、責務混在の有無。
4. Regression
   - 主要導線の応答・処理時間が悪化していないか。

## Quantitative Gate
- 新規 N+1: 0
- 主要導線の不要通信増加: 0
- 高優先度の境界違反（モジュール責務崩壊）: 0

## Required Evidence
- 計測コマンドと結果（before/after）
- ボトルネック一覧と修正内容
- 再検証結果（Unit/Integration/E2E）
- residual risks（該当時）

## Output Template
```md
## Bottleneck Findings
| Severity | Layer | File | Symptom | Status |
|---|---|---|---|---|

## Architecture Findings
| Severity | Module | Issue | Decision | Status |
|---|---|---|---|---|

## Measurement
- Before:
- After:

## Verification
- Commands:
- Results:

## Residual Risks
- 
```

## Done Criteria
- Performance/Architecture の High 未解決が 0。
- 計測結果と改善結果が証跡化されている。
- 関連テストで回帰なしを確認済み。
