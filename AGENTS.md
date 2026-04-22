# AGENTS 共通ルール

このファイルは、Coordinator / Detector / Writer / Solver すべてに適用する共通運用ルールです。

## 目的
- 不具合を素早く正確に検知し、GitHub Issues に蓄積し、修復まで自動化する。
- Issue を不具合DBとして扱い、重複を抑制し、履歴を一元管理する。

## 共通原則
1. まず重複チェック
   - 新規Issue作成前に github/search_issues を必ず実行する。
2. 証拠ベース
   - すべての結論にログ、テスト結果、差分、再現手順を添える。
3. 信頼度の明示
   - high / medium / low confidence を常に明記する。
4. 優先度の統一
   - high-priority / med-priority / low-priority をラベルで付与する。
5. 日本語中心で可読性重視
   - タイトルは短く、本文は構造化する。
6. 実装とテストは同時更新
   - 機能変更時は、同じ作業サイクル内で関連テストを遅延なく更新する。
   - 新規実装時は、実装完了タイミングでUnitテストとE2Eテストを遅延なく追加する。
   - 「コードだけ先にマージしてテストは後追い」は禁止する。

## 強制運用（Fail-Closed）
1. 品質ゲート未達は完了不可
   - 必須証跡が不足している場合は、Issue更新・PR提案・完了宣言を禁止する。
2. 実装先行禁止
   - テスト未更新の実装変更は完了扱いにしない。
3. 検証未完了禁止
   - 再現テスト、関連テスト、回帰確認のいずれか未実施なら未完了扱いとする。

## スキル適用規約
1. 設計判断が必要な変更
   - `.github/skills/solver-design-guardrails/SKILL.md` を先に適用する。
2. テスト追加・更新が必要な変更
   - `.github/skills/solver-test-authoring/SKILL.md` を適用する。
3. 複合変更（設計 + 実装 + テスト）
   - design-guardrails -> test-authoring の順で併用する。

## 境界判定ルール（Design vs Test）
- 次のいずれかに該当する場合は Design 先行:
  - 変更ファイルが3件以上
  - モジュール境界をまたぐ
  - セキュリティ/パフォーマンス影響がある
- 次のいずれかに該当する場合は Test 先行:
  - 既存不具合の再現が明確
  - 受け入れ条件がテストケースに直結する

## エスカレーション規約
1. Detector -> Coordinator
   - 再現不能、証拠不足、環境起因疑いがある場合は low-confidence で即時エスカレーション。
2. Solver -> Coordinator
   - 3回以内の修正試行で安定化しない場合、または外部依存障害で進行不能な場合にエスカレーション。
3. Writer -> Coordinator
   - 重複判定が曖昧、またはSeverity判断が分かれる場合にエスカレーション。

## 定量品質ゲート（最低基準）
- Security
  - 認証/認可/入力検証の回帰テストが追加または既存で担保されている。
  - 機密情報露出（トークン、秘密鍵、内部スタックトレース）が増えていない。
- Performance
  - 主要APIの不要なクエリ増加がない（N+1を導入しない）。
  - フロントエンドの主要導線で不要再レンダリングや過剰通信を増やさない。
- Test
  - 変更対象に対応するUnitまたはIntegrationテストが更新されている。
   - API/DB/認可境界をまたぐ検証は結合試験で保護し、原則としてAPIモックを禁止してローカルの実バックエンドへ接続する。
  - 画面導線変更時はE2Eで回帰検知が追加または維持されている。
  - E2Eで`console.error`/`pageerror`/`5xx`を未解消のまま残さない。
   - E2Eで検知した実行時エラーは不具合シグナルとしてDetector -> Solverへ引き継ぎ、同一サイクルで自動修復と再検証を試みる。

## 未テスト領域検出ループ（必須）
- 既存テストのpassのみで完了判定しない。未テスト導線の検出とテスト化を同一エコシステムに含める。
- 各サイクルで以下を必ず実行する。
   - テスト対象インベントリを更新する（画面、API、認可境界、異常系、外部連携）。
   - インベントリと既存テストの対応表（traceability）を更新し、未カバー項目を抽出する。
   - 高リスク未カバー項目から順に failing test を先に追加する。
   - 結合試験は実バックエンド接続を前提とし、外部SaaSなど制御不能な依存を除いてモックで代替しない。
   - 最小修正後に Unit/Integration/E2E を再実行し、回帰と副作用を確認する。
   - E2Eの`console.error`/`pageerror`/`requestfailed`/`5xx`はテスト失敗と同等に扱い、根本原因分析と自動修復ループへ投入する。
- 未テスト項目は severity と confidence を付けて Issue 管理する（重複禁止）。

## 自動停止条件（真に改善点ゼロ）
- 以下をすべて満たしたときのみ、Coordinator は自動停止して完了宣言できる。
   - Critical/High の未解決が 0。
   - 連続2サイクルで新規不具合が 0。
   - 高リスク未テスト項目が 0。
   - Security/Performance/Test の定量品質ゲート未達が 0。
- いずれか未達なら停止せず、再帰ループを継続する。

## ラベル標準
- 必須: bug, auto-detected
- 優先度: high-priority, med-priority, low-priority
- 状態補助: needs-review, flaky-test, regression, security

## 禁止事項
- 証拠なしの断定
- 重複Issueの乱立
- テスト未実行のまま「修正完了」とすること

## 完了条件
- 検知: 根本原因仮説 + 影響範囲 + 重複チェック結果がある
- 記録: Issueが新規作成または既存更新されている
- 修復: 修正 + 再テスト結果 + PRまたは未解決理由がある
- 実装変更: 変更と同一タイミングでテスト更新が完了し、証跡がある
- 定量ゲート: Security/Performance/Test の最低基準を満たし、未達項目がない
- 未テスト管理: テスト対象インベントリとtraceabilityが更新され、高リスク未テストが残っていない
- 停止判定: 自動停止条件（真に改善点ゼロ）を満たしている

## 利用者向けスキル参照
- 設計時のガードレール: .github/skills/solver-design-guardrails/SKILL.md
- テスト作成時のガードレール: .github/skills/solver-test-authoring/SKILL.md
- コミット作成: .github/skills/writer-commit-management/SKILL.md
   - 実行規約: コミット作業は `writer` エージェントを呼び出し、コミット件名は日本語を必須とする
- リリース作成/ノート更新: .github/skills/writer-release-management/SKILL.md
   - 実行規約: リリース作業は `writer` エージェントを呼び出して実施する
   - 追加規約: リリース前に README/docs/AGENTS のブラッシュアップを必須実施する
- 参照ガイド: docs/skills/README.md
- 強制品質ゲート指示: .github/instructions/quality-gates.instructions.md
