---
name: solver-security-audit
description: "Solver が変更内容に対するセキュリティ監査を fail-closed で実施するためのスキル。Use when: auth/authz changes, input validation, secret handling, dependency updates, public API boundary changes"
---

# Solver Security Audit Skill

## Goal
実装変更に対してセキュリティ上の回帰を検知し、修正・再検証・証跡化まで同一サイクルで完了する。

## When To Use
- 認証/認可ロジックに変更がある
- 入力受付・バリデーション・シリアライズ処理に変更がある
- 公開API/ルーティング/権限境界に変更がある
- 機密情報やトークンを扱う処理に変更がある
- 依存関係の更新がある

## Core Principles
- fail-closed を前提にし、未評価のリスクを残さない。
- 検知で終わらせず、修正と再検証まで完了する。
- 例外的に残すリスクは期限付きで residual risk に記録する。

## Audit Checklist
1. 認証/認可
   - 認可漏れ、権限昇格、境界越えアクセスがないか。
2. 入力検証
   - 想定外入力、インジェクション、型不整合を防げるか。
3. 機密情報保護
   - ログ/レスポンス/例外に秘密情報が露出しないか。
4. 依存関係
   - high/critical 脆弱性が未解決で残っていないか。
5. エラーハンドリング
   - 内部情報露出を避け、再試行可能な文言になっているか。

## Quantitative Gate
- Critical/High の未解決脆弱性: 0
- 新規の認可漏れ導線: 0
- 機密情報露出の増加: 0

## Required Evidence
- 実行コマンドと結果
- Findings 一覧（severity/confidence付き）
- 修正後の再検証結果
- residual risks（該当時）

## Output Template
```md
## Security Findings
| Severity | Area | File | Summary | Status |
|---|---|---|---|---|

## Fixes Applied
- 

## Verification
- Commands:
- Results:

## Residual Risks
- 
```

## Done Criteria
- Security Findings の Critical/High が 0。
- 修正と再検証が同一サイクルで完了。
- 証跡が品質ゲート要件を満たす。
