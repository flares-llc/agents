---
name: solver-frontend-wcag-audit
description: "Solver がフロントエンドの WCAG 基礎違反を監査し、未解決重大項目を同一サイクルで 0 件化するためのスキル。Use when: frontend route changes, component semantics updates, accessibility hardening"
---

# Solver Frontend WCAG Audit Skill

## Goal
主要導線の WCAG 基礎違反を fail-closed で検知し、同一サイクルで解消する。

## When To Use
- 画面導線、ナビゲーション、一覧/フォームUIの変更
- aria属性、ラベル、画像代替テキスト、見出し構造の変更

## Core Principles
- 監査はルート横断で自動化し、手動確認のみで完了扱いにしない。
- 誤検知を抑えるために可視要素中心で評価し、重大違反は厳格に fail させる。
- 検出時は対象ノードセレクタとルートを証跡に残す。

## Audit Checklist
1. 代替テキスト
   - 意味を持つ画像に alt がある
2. ラベル/操作要素名
   - input/select/textarea/button がアクセシブル名を持つ
3. 構造
   - 見出し階層や landmark の欠落を放置しない
4. コントラスト/識別
   - 主要導線で視認不能要素を残さない

## Quantitative Gate
- Critical/Serious WCAG 違反: 0
- 主要導線での代替テキスト欠落: 0
- 主要導線での unlabeled interactive controls: 0

## Required Evidence
- 監査対象ルート
- 検出ルールID
- 失敗ノード
- 修正前後の実行結果

## Done Criteria
- WCAG監査テストが pass。
- 未解決重大項目が 0。
- 品質ゲートで自動実行される。
