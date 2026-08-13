# Native Delegation Playbook

Use this reference only when delegation is selected or a structured investigation template is useful. `SKILL.md` is the source of truth for routing, limits, writer ownership, and strict model verification.

## Delegation preflight

Delegate only when all conditions pass:

1. Native subagent capability is available.
2. The child can be explicitly selected as `gpt-5.6-luna` with `xhigh` reasoning.
3. That selection can be enforced and reliably verified, preferably from returned runtime metadata.
4. The run still has room within its maximum of 3 total child sessions.

Merely requesting Luna xhigh does not establish that it was used. If any condition fails, do not spawn and continue DIRECT. Preserve the task's previously selected depth; for substantial work, follow `direct-deep-playbook.md`. Never inherit a different model or effort, and never create an external fallback. **Unverified xhigh = no delegation.**

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

Always include `Do not create subagents.` Set `FORBIDDEN_ACTIONS` to implementation, file modification, external writes, destructive actions, and scope expansion. Every child is read-only. Do not leak a preferred conclusion or ask for hidden chain-of-thought.

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

Main checks material claims before implementation or final reporting.

## Child lifecycle

- `DONE` → use the receipt after checking material claims.
- `DONE_WITH_CONCERNS` → main evaluates the concerns before using the receipt.
- `NEEDS_CONTEXT` → main may send at most one bounded follow-up to the same child; that follow-up consumes one unit of the same total child-session budget.
- `BLOCKED` or failed → do not open an automatic replacement child.
- Treat a completed child as closed.
- A failure never grants another child session or resets the maximum of 3 total sessions.

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

Every child is read-only. Main Luna Max is the only writer and owns all implementation, file changes, validation, and final reporting. Concurrent child work is limited to investigation and review.
