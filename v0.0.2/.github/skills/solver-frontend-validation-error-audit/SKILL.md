---
name: solver-frontend-validation-error-audit
description: "Solver がフォームの required/invalid エラー品質を監査し、利用者が次行動を判断できるエラー提示を担保するためのスキル。Use when: form changes, validation message updates, submission flow changes"
---

# Solver Frontend Validation Error Audit Skill

## Goal
required 入力の失敗時に、検知可能で行動可能なバリデーションエラーが必ず提示される状態を維持する。

## When To Use
- フォーム項目、入力制約、送信処理の変更
- エラーメッセージ文言や表示位置の変更

## Core Principles
- required 未入力は必ず invalid として観測可能にする。
- `aria-invalid` と `aria-describedby` を連動させ、支援技術で追跡可能にする。
- 文言は「何が起きたか」「次に何をすべきか」を含める。

## Audit Checklist
1. Validation trigger
   - required 未入力 submit で invalid が発火する
2. Invalid semantics
   - invalid 時に `aria-invalid=true` を設定する
3. Actionable message linkage
   - `aria-describedby` が有効なメッセージノードを参照する
4. Message quality
   - メッセージが空ではない
5. Operability parity
   - 画面に表示されている入力要素は、`disabled/readOnly` でない限り操作可能であること
   - `inert` 配下、`pointer-events: none`、`tabIndex < 0` による実質操作不能を検知する

## Quantitative Gate
- required 未入力時の未検知: 0
- invalid semantics 欠落 (`aria-invalid`/`aria-describedby`): 0
- 空メッセージ/行動不明メッセージ: 0
- 可視入力の操作不能要素（意図しない inert / pointer-events:none / tabIndex<0）: 0

## Required Evidence
- 監査対象フォーム/ルート
- 失敗フィールドID
- 不足した属性や文言
- 修正前後の実行結果

## Done Criteria
- バリデーション監査テストが pass。
- 未解決重大項目が 0。
- 品質ゲートで自動実行される。
