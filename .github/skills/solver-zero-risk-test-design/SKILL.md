---
name: solver-zero-risk-test-design
description: "リスク0を目標に試験設計を標準化し、fail-closedで検証を完了させるスキル。Use when: zero-risk test planning, deterministic verification, traceability standardization, mandatory quality gates"
---

# Solver Zero Risk Test Design Skill

## Goal
変更ごとに試験設計を標準化し、未検証領域・未解決重大項目・残留リスクを 0 件にする。

## Mandatory Policy
- 「low residual risk」は不許可。`Residual Risks: none` 以外は完了不可。
- 実装変更時は Unit/Integration/E2E を同一サイクルで更新する。
- API/DB/認可境界の検証はローカル実バックエンド接続を必須にする。
- quick 通過は中間確認であり、完了判定は deterministic 通過を必須にする。

## Standard Test Design Matrix
各変更に対して必ず以下を埋める。

```md
## Test Design Matrix
| Contract | Risk | Unit | Integration | E2E | Runtime Signal Guard | Owner |
| --- | --- | --- | --- | --- | --- | --- |
| <API/UI/DB contract> | high/med/low | <test id> | <test id> | <test id> | console.error/pageerror/requestfailed/5xx | <agent> |
```

## Test Effectiveness Triad (Mandatory)
以下の3概念を毎サイクルで定義し、traceabilityに紐づける。

### 1. Mutation Testing Design
- Target module:
- Mutation strategy (operator/category):
- Expected kill criteria:
- Planned execution tool (Phase 2): `Stryker` (JS/TS) など

### 2. Property-Based Testing Design
- Property / invariant:
- Input generators and constraints:
- Shrinking expectation:
- Planned execution tool (Phase 2): `fast-check` (JS/TS) など

### 3. Semantic Regression Analysis Design
- Change summary:
- Existing tests expected to detect change:
- Detection gap hypothesis:
- Added or planned test to close the gap:

## Required Execution Order
1. `npm run qa:artifacts:init`
2. `npm run qa:customizations:validate`
3. `npm run qa:zero-risk:contract`
4. `npm run guard:verify:quick`
5. `QA_ARTIFACTS_STRICT=1 npm run guard:verify:full`
6. `npm run guard:verify:deterministic`

## Gate Criteria
- Security監査: Critical/High = 0
- Performance/Architecture監査: High = 0
- WCAG監査: unresolved major = 0
- Validation監査: unresolved major = 0
- Traceability: `passed` のみ許可
- Residual risks: `none` 固定

## Failure Handling
- いずれかのゲート失敗時は完了宣言禁止。
- `npm run qa:artifacts:init` で新サイクルを生成し、失敗原因の修正と再検証を同一サイクルで完了する。

## Output Contract
```md
### Verification Evidence
- Commands:
- Failed result:
- Fixed result:
- Impact scope:
- Residual Risks: none
```

## Done Criteria
- Test Design Matrix が埋まり、すべての high risk 項目が Unit/Integration/E2E いずれかで保護されている。
- Test Effectiveness Triad（Mutation / Property-Based / Semantic Regression）が定義されている。
- deterministic を含む全ゲートが通過している。
- 未解決重大項目と residual risks が 0 件である。