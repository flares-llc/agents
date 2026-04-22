---
name: writer-commit-management
description: "Writer がコミット作成を一貫運用し、日本語コミットメッセージを強制するためのスキル。Use when: create commit, split commits, enforce japanese commit messages"
---

# Writer Commit Management Skill

## Goal
コミット作成手順を標準化し、コミット件名を日本語で統一する。

## Mandatory Invocation Contract
- コミット作成を行う場合、必ず `writer` エージェントを呼び出して本スキルを適用する。
- `writer` を経由せずに `git commit` を直接実行して完了扱いにしない。
- コミット件名は日本語を必須とする（`commit-msg` hook により fail-closed）。

## When To Use
- 変更を論理単位でコミットするとき
- リリース前にコミット分割/整理を行うとき
- コミットメッセージ品質を統一するとき

## Preflight Checklist
1. 変更差分を確認する。
   - `git status --short`
   - `git diff --stat`
2. フックを有効化する。
   - `npm run hooks:install`
3. コミット単位を決める。
   - 1コミット1意図で分割する。

## Execution Steps
1. 変更をステージする。
   - `git add <files>` または `git add -A`
2. 日本語件名でコミットする。
   - `git commit -m "feat: 日本語の件名"`
3. 必要に応じて push する。
   - `git push origin <branch>`
4. 結果を確認する。
   - `git log --oneline -n 5`

## Message Guidelines
- 先頭は Conventional Commits 形式を推奨（`feat:` / `fix:` / `docs:` / `chore:` など）。
- 件名は日本語で簡潔に、変更意図がわかる文にする。
- 本文が必要な場合も日本語を基本とする。

## Quality Gates
- コミット件名に日本語が含まれている。
- `commit-msg` hook で拒否されるメッセージを使っていない。
- コミットが論理単位で分割されている。
- 実行コマンドと最終コミットIDを証跡として提示できる。

## Failure Handling
- 英語のみ件名で失敗した場合は、日本語件名へ修正して再コミットする。
- hook 未導入の場合は `npm run hooks:install` 実行後に再試行する。
- まとめすぎたコミットは `git reset --soft HEAD~1` で再分割する。

## Done Criteria
- 日本語件名でコミットが作成されている。
- 直近ログで件名ルール順守を確認できる。
- 必要な push と共有情報（SHA）が揃っている。
