---
applyTo: "**"
---

# Quality Gate Instructions (Fail-Closed)

このワークスペースで実装変更を行う場合、以下の条件を満たさない限り「完了」として扱わない。

## Mandatory Gates
1. 実装とテストの同時更新
- 実装変更がある場合、同一サイクルで関連テストを更新する。
- 新規実装は Unit と E2E を同時に追加する。

2. 証跡の提示
- 実行コマンド
- 失敗時/修正後の結果
- 影響範囲
- residual risks

3. 非機能ゲート
- Security: 認証/認可/入力検証/機密情報露出の回帰なし
- Performance: N+1 と過剰通信を新規導入しない
- Test: console.error/pageerror/5xx を未解消で残さない

## Skill Invocation Rules
- 設計判断を伴う変更は `solver-design-guardrails` を先に適用する。
- テスト追加/更新を伴う変更は `solver-test-authoring` を適用する。
- 複合変更は design-guardrails -> test-authoring の順で適用する。

## Completion Guard
次のいずれかが未達なら完了不可:
- テスト更新が未実施
- 再検証が未実施
- 証跡が不足
- Security/Performance/Test のいずれかが未達
