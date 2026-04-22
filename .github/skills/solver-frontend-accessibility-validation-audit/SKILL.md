---
name: solver-frontend-accessibility-validation-audit
description: "フロントのアクセシビリティとバリデーションを統合監査する補助スキル。Use when: combined wcag and required validation audits on frontend routes"
---

# Solver Frontend Accessibility/Validation Audit Skill

## Goal
WCAG 基礎監査と required バリデーション監査を同一サイクルで実行し、導線品質を一括で担保する。

## When To Use
- 画面導線変更かつフォーム変更を同時に含む場合
- 監査を 1 回の実行でまとめたい場合

## Required Commands
1. `npm run test:qa:frontend:wcag-audit`
2. `npm run test:qa:frontend:validation-audit`
3. `npm run test:qa:line:wcag-audit`
4. `npm run test:qa:line:validation-audit`

## Done Criteria
- 未解決重大項目が 0
- required 入力エラーが検知可能
- 次行動が分かるメッセージが表示される
