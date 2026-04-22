---
name: solver-test-authoring
description: "Solver が不具合修正時に回帰テストを作成・更新するための実践スキル。Use when: add regression test, write failing test first, fix flaky test, update Vitest/Playwright test, issue-driven test authoring"
---

# Solver Test Authoring Skill

## Goal
不具合修正のたびに、再発防止に直結する最小テストを一貫した品質で追加・更新する。

## Timing Policy
- 機能変更時は、同じ変更セット内でテスト更新を完了させる（遅延禁止）。
- 新規実装時は、実装完了タイミングで Unit テストと E2E テストを同時に追加する。
- テストが未更新の状態で実装だけを完了扱いにしない。

## When To Use
- Issue 起点で修正するが、再発防止テストが不足しているとき
- 失敗再現はできるが、テストケースが症状を固定できていないとき
- flaky なテストを安定化しつつ期待挙動を保証したいとき

## Inputs
- Issue 番号と受け入れ条件
- 再現手順
- 失敗ログ（テスト名、スタックトレース、エラー文言）

## Workflow
1. 失敗を再現する。
   - まず既存の失敗テストだけを実行し、症状を固定する。
2. 原因とテスト粒度を決める。
   - Unit で閉じるなら Unit、API連携は結合試験、画面遷移や統合導線は E2E を選ぶ。
3. 先に失敗するテストを作る。
   - 「何が壊れているか」が 1 つ明確になる最小ケースにする。
4. 最小修正を実装する。
   - テストを通すために必要な範囲だけ変更する。
5. 検証を広げる。
   - 失敗ケース -> 関連スイート -> 全体スモークの順に再実行する。
6. 記録する。
   - Issue に修正内容、追加テスト、再実行結果、残リスクを追記する。

## Test Design Rules
- 1 テスト 1 意図。複数原因を1ケースに混ぜない。
- 実装詳細ではなく外部契約（入力/出力/画面挙動）を検証する。
- ランダム値・現在時刻・外部通信は固定またはモックする。
- 日本語UI文言を検証する場合は、意味の核になる文言を狙う。
- 例外文言は「何が起きたか/なぜ/次の行動」が伝わるかを確認する。

## Integration Test Policy
- 結合試験では API モックを使わず、必ずローカルの実バックエンドへ接続して検証する。
- テスト実行前にバックエンドの起動確認と疎通確認を行う（例: health endpoint）。
- DB や初期データは再現可能な状態に固定し、テスト間の状態汚染を防ぐ。
- モック許可は外部SaaSなど制御不能な依存に限定し、理由をIssueに明記する。

## Framework Guidance

### Vitest (unit/e2e-like)
- 失敗テストを先に追加し、修正前に fail を確認する。
- 非同期は `await` を徹底し、タイミング依存を避ける。
- データ境界（null/empty/unauthorized/5xx）を優先して追加する。

### Playwright (e2e)
- 画面要素待機は `expect(...).toBeVisible()` など明示的に行う。
- E2E の主経路はローカル実バックエンド接続を優先し、検知範囲を実運用に寄せる。
- ブラウザの `console.error` は不具合シグナルとして扱い、期待されたケース以外は失敗にする。
- `pageerror` / `requestfailed` / 5xx 応答を収集し、失敗時に証跡を残す。
- 認証・API のモックは特定ケースの最小範囲に限定し、未使用時は実接続で検証する。

## Done Criteria
- 追加/更新したテストが「修正前に fail、修正後に pass」を満たす。
- 関連スイート再実行で回帰なし。
- Issue に再現手順、テスト証跡、confidence が記録されている。
- 結合試験とE2Eで、ブラウザコンソールエラーを含む実行時エラーが未解消のまま残っていない。
- 実装変更とテスト更新が同一サイクルで完了している。

## Output Template
```md
### Added/Updated Tests
- <path/to/test>: <what this test protects>

### Validation
- before: <failed command/result>
- after: <passed command/result>

### Confidence
- high|medium|low

### Residual Risks
- <remaining risk or none>
```
