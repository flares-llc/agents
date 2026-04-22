# Skills ガイド

利用者が参照しやすいように、エージェント運用で使う主要スキルを整理しています。

## 設計時に使うスキル
- `.github/skills/solver-design-guardrails/SKILL.md`
  - 目的: 実装前設計で、共通化・最小変更・セキュリティ・パフォーマンスを先に固める。
  - 主な利用場面: 設計レビュー、変更範囲の絞り込み、非機能要件評価。

## テスト作成時に使うスキル
- `.github/skills/solver-test-authoring/SKILL.md`
  - 目的: 不具合修正時の回帰テスト追加と再検証を標準化する。
  - 主な利用場面: failing test先行、結合試験、E2E品質ゲート運用。
  - 運用ルール: 機能変更時はテストを遅延なく同時更新し、新規実装時はUnit/E2Eを同時実装する。

## リリース運用時に使うスキル
- `.github/skills/writer-release-management/SKILL.md`
  - 目的: `gh` コマンドで Release 作成と Release Notes 更新を標準化する。
  - 主な利用場面: バージョンリリース作成、既存リリースノート更新。
  - 運用ルール: Release作業は必ず `writer` エージェントを呼び出し、本スキルを適用して実施する。

## 利用の目安
1. 設計を先に固めたいときは design-guardrails を使う。
2. 修正に合わせてテストを作るときは test-authoring を使う。
3. Release作業は writer-release-management を使い、`writer` エージェント経由で実行する。
4. 両方必要なときは、設計 -> 実装/テストの順で併用する。

## 境界判定（Design vs Test）
- Design 先行
  - 変更ファイルが3件以上
  - モジュール境界をまたぐ
  - セキュリティ/パフォーマンス影響がある
- Test 先行
  - 不具合再現が明確
  - 受け入れ条件がテストケース化しやすい

## クイックスタート
1. 設計レビューが必要なら `solver-design-guardrails` を読み、Design Output Template を埋める。
2. 実装と同時に `solver-test-authoring` を読み、failing test を先に追加する。
3. 修正後に関連テストを再実行し、Issue に証跡を追記する。

## 入力テンプレート
```md
- Issue: #<number>
- Symptom:
- Reproduction:
- Acceptance Criteria:
- Affected Modules:
```

## 出力テンプレート
```md
## Decision
- Applied Skill: design-guardrails | test-authoring | both
- Reason:

## Evidence
- Commands:
- Test Results:
- Residual Risks:
```

## よくある失敗と対策
- 失敗: 実装だけ先に完了扱いする
  - 対策: 同一サイクルでUnit/E2E更新を必須にする
- 失敗: 設計スキルを飛ばして変更範囲が肥大化する
  - 対策: 変更3ファイル以上はDesign先行を固定する
- 失敗: E2Eでconsole.errorを見落とす
  - 対策: 品質ゲートでconsole.error/pageerror/5xxを必須確認にする
