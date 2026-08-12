# Native Delegation Playbook

Use this reference only when delegation is selected or a structured investigation template is useful. `SKILL.md` is the source of truth for routing, limits, writer ownership, and model fallback.

## Task packet

Send compact task-local context rather than the full conversation:

```text
GOAL:
SCOPE:
RELEVANT_PATHS:
KNOWN_EVIDENCE:
QUESTION_TO_ANSWER:
CONSTRAINTS:
FORBIDDEN_ACTIONS:
EXPECTED_OUTPUT:
```

Always include `Do not create subagents.` Default `FORBIDDEN_ACTIONS` to implementation, external writes, destructive actions, and scope expansion unless explicitly authorized. Do not leak a preferred conclusion or ask for hidden chain-of-thought.

## Structured receipt

Require this shape:

```text
STATUS: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
SUMMARY:
FINDINGS:
EVIDENCE: path/function/line/command/observed behavior
CONFIDENCE: low | medium | high
RISKS:
RECOMMENDED_NEXT_ACTION:
```

For an explicitly authorized writer, also require:

```text
FILES_CHANGED:
TESTS_RUN:
VALIDATION_RESULT:
```

Main checks material claims before implementation or final reporting.

## Bug investigation

- DIRECT when reproduction and root cause are already clear.
- DELEGATED: one investigator traces reproduction and cause; optionally one independent investigator challenges it.
- FANOUT only for complex regressions: reproduction/root cause, independent analysis, and falsification or regression surface.
- Main compares evidence, reproduces the decisive path, implements the fix, and checks regressions.

## Feature work

- Optional scout: impacted architecture, conventions, files, hidden risks.
- Optional alternative: materially different approach and tradeoffs.
- Main selects and implements.
- Optional reviewer inspects the final diff against requirements and regressions.
- Skip roles that cannot change the decision or validation.

## Repository audit

Use non-overlapping information lanes, for example:

- runtime, state, and data flow;
- architecture and API boundaries;
- tests, error handling, and regression coverage.

Main merges duplicates, rejects speculation, verifies evidence, calibrates severity, and implements only when authorized.

## Writer ownership

Default every child to read-only investigation. Delegate implementation only when ownership is explicit and disjoint, such as `packages/auth/**` versus `packages/player/**`. Stop or re-scope work immediately if file ownership begins to overlap.
