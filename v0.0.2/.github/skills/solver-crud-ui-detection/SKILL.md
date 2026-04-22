---
name: solver-crud-ui-detection
description: "CRUD契約とUI操作性の検出精度を高めるスキル。Use when: create/read/update/delete regression detection, ui interactability audits, runtime signal triage"
---

# Solver CRUD/UI Detection Skill

## Goal
CRUD 操作が正しく完了することと、UI 上で要素が選択・入力・送信可能であることを同時に検証し、未検知不具合を減らす。

## When To Use
- API もしくは画面で Create/Read/Update/Delete に変更があるとき
- 「押せない」「選べない」「入力できない」「保存できない」系不具合があるとき
- console.error/pageerror/requestfailed/5xx が E2E で観測されたとき

## Detection Checklist
1. CRUD 契約
- Create: 成功レスポンス、永続化、重複時のエラー品質
- Read: 一覧/詳細の整合、空状態の文言、認可境界
- Update: 反映確認、競合時メッセージ、再試行導線
- Delete: 論理/物理削除整合、参照中制約のエラー品質

2. UI 操作性
- 可視 input/select/textarea/button が操作可能である
- pointer-events:none / inert / tabIndex<0 の意図しない適用がない
- フォーカス移動とキーボード操作が成立する
- required 未入力時に invalid と関連メッセージが提示される

3. 実行時シグナル
- console.error = 0
- pageerror = 0
- requestfailed = 0
- 5xx = 0

## Test Strategy
- Backend Integration: API/DB/認可境界を実バックエンドで検証する
- Frontend/line E2E: 実際の画面操作で CRUD を完了させる
- Unit: 入力検証・エラーメッセージ生成などを局所検証する

## Traceability Contract
各 CRUD 導線を `06-traceability.csv` へ登録し、status を `passed` で閉じる。

## Done Criteria
- 変更対象 CRUD 導線が Unit/Integration/E2E のいずれかで保護されている
- 高リスク導線は Integration + E2E の両方で保護されている
- 実行時シグナル未解決 0 件
