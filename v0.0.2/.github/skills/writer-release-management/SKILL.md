---
name: writer-release-management
description: "Writer が gh コマンドで GitHub Release を作成し、リリースノートを一貫した品質で作成・更新するためのスキル。Use when: create release, update release notes, publish snapshot versions"
---

# Writer Release Management Skill

## Goal
`gh` コマンドを使ったリリース作成とリリースノート整備を標準化し、重複作成や記載漏れを防ぐ。

## Mandatory Invocation Contract
- リリース作成またはリリースノート更新を行う場合、必ず `writer` エージェントを呼び出して本スキルを適用する。
- `writer` を経由せずに `gh release create` / `gh release edit` を直接実行して完了扱いにしない。

## When To Use
- 新しいバージョンタグで Release を作成するとき
- 既存 Release のノート本文を追記・修正するとき
- 変更サマリーをコミット履歴に基づいて整形するとき

## Preflight Checklist
1. タグ重複を確認する。
   - `git tag --list | sort -V`
2. 既存 Release を確認する。
   - `gh release list --limit 20`
3. 対象 Release の現状本文を確認する。
   - `gh release view <tag> --json tagName,name,body,url`

## Execution Steps
1. リリース本文を下書きする（テンポラリファイル推奨）。
2. 新規作成時:
   - `gh release create <tag> --title "<title>" --notes-file <notes-file>`
3. 更新時:
   - `gh release edit <tag> --notes-file <notes-file>`
4. 反映確認:
   - `gh release view <tag> --json tagName,name,body,url,isDraft,isPrerelease`

## Release Notes Template
```md
## <version> Release Notes

### Highlights
- ...

### Main Changes
- docs: ...
- prompts: ...
- scripts: ...

### Included Commits
- `<sha>` <subject>

### Upgrade Notes
- ...
```

## Quality Gates
- タグと Release の不整合がない。
- ノートに最低限 `Highlights` / `Main Changes` / `Included Commits` / `Upgrade Notes` がある。
- 公開状態（draft / prerelease）の意図が明示されている。
- 実行コマンドと確認結果（URL）を証跡として残す。

## Failure Handling
- 既存タグがある場合は、新規作成ではなく `gh release edit` に切り替える。
- 認証エラー時は `gh auth status` を確認し、解消後に再実行する。
- ノート反映失敗時は本文取得結果と差分を提示して再試行する。

## Done Criteria
- 対象 Release が期待するタグ・タイトル・公開状態で存在する。
- リリースノートがテンプレート要件を満たし、最新内容に更新されている。
- `gh release view` の確認結果を提示できる。
