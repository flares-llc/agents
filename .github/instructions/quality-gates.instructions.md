---
applyTo: "**"
---

# Quality Gate Instructions (Fail-Closed)

このワークスペースで実装変更を行う場合、以下の条件を満たさない限り「完了」として扱わない。

## Mandatory Gates
0. テスト有効性設計ゲート（Phase 1: 定義の強制）
- Mutation Testing / Property-Based Testing / セマンティック差分回帰分析の3概念を、エージェント・スキル・プロンプト定義に明記する。
- Phase 1 では「定義と契約検証」を必須化し、実行基盤の導入は次段で行う。

1. 実装とテストの同時更新
- 実装変更がある場合、同一サイクルで関連テストを更新する。
- 新規実装は Unit と E2E を同時に追加する。

2. 証跡の提示
- 実行コマンド
- 失敗時/修正後の結果
- 影響範囲
- residual risks（`none` 固定。期限付き残置は許可しない）
- `qa-artifacts/cycle-*/` の必須アーティファクト
	- `00-run-context.json`
	- `01-skill-decision.json`
	- `02-security-audit.json`
	- `03-performance-architecture-audit.json`
	- `05-validation.json`
	- `06-traceability.csv`
	- `08-residual-risks.md`

3. 結合試験ゲート
- API/DB/認可境界をまたぐ変更は、モックではなくローカルの実バックエンドに接続する結合試験で検証する。
- モック許可は外部SaaSなど制御不能な依存に限定し、理由を証跡へ残す。

4. 非機能ゲート
- Security: 認証/認可/入力検証/機密情報露出の回帰なし
- Performance: N+1 と過剰通信を新規導入しない
- Accessibility: フロントエンドの主要導線で WCAG 基礎違反（代替テキスト/ラベル/操作要素名）を未解消で残さない
- Validation: required 入力の未入力時エラーが検知可能で、次の行動が分かるバリデーションメッセージ欠落を残さない
- Test: console.error/pageerror/5xx を未解消で残さない
- Runtime Auto-Heal: E2Eや結合試験で観測したconsole.error/pageerror/requestfailed/5xxは実行時エラーとして扱い、根本原因分析と自動修復を同一サイクルで再試行する

5. 決定性ゲート
- 再現性が必要な検証では `npm run guard:verify:deterministic` を実行し、アーティファクト契約検証を通過する。
- 失敗時は `npm run qa:artifacts:init` でサイクルを再生成し、必要な証跡ファイルを更新して再実行する。
- 完了判定時は deterministic 通過を必須とし、quick/full のみでの完了宣言を禁止する。

6. 監査クローズゲート
- Security監査（`solver-security-audit`）の Critical/High が 0 件であること。
- Performance/Architecture監査（`solver-performance-architecture-audit`）の High が 0 件であること。
- 監査未解決項目を残す場合は期限付き residual risks を証跡に記録すること。

## Skill Invocation Rules
- リスク0試験設計の標準化が必要な変更は `solver-zero-risk-test-design` を先に適用する。
- 設計判断を伴う変更は `solver-design-guardrails` を先に適用する。
- セキュリティ影響を伴う変更は `solver-security-audit` を適用する。
- パフォーマンス/構成影響を伴う変更は `solver-performance-architecture-audit` を適用する。
- フロント導線変更を伴う変更は `solver-frontend-wcag-audit` を適用する。
- フォーム変更を伴う変更は `solver-frontend-validation-error-audit` を適用する。
- CRUD契約またはUI操作性変更を伴う変更は `solver-crud-ui-detection` を適用する。
- テスト追加/更新を伴う変更は `solver-test-authoring` を適用する。
- 複合変更は solver-zero-risk-test-design -> design-guardrails -> security-audit -> performance-architecture-audit -> frontend-wcag-audit -> frontend-validation-error-audit -> solver-crud-ui-detection -> test-authoring の順で適用する。

## Completion Guard
次のいずれかが未達なら完了不可:
- テスト更新が未実施
- 再検証が未実施
- 証跡が不足
- Security/Performance/Test のいずれかが未達
- Accessibility/Validation のいずれかが未達
- Security監査が未クローズ
- Performance/Architecture監査が未クローズ
- deterministic 検証が未実施または未通過
- Residual Risks が `none` でない
- 3概念（Mutation / Property-Based / Semantic Regression）の定義が欠落している
