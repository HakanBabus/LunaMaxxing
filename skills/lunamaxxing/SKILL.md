---
name: lunamaxxing
description: Orchestrate difficult work with a quality-first Luna Max main session and bounded native subagents. Use only when the user explicitly invokes $lunamaxxing or directly instructs Codex to use the lunamaxxing skill. Do not invoke merely because a request mentions Luna, Luna Max, quality, deep analysis, planning, debugging, or verification.
---

# LunaMaxxing

Keep the current session as task owner. Assume the intended main runtime is **`gpt-5.6-luna` with `max` reasoning**, but claim it only when runtime metadata verifies it. Never start an external process to force a model or reasoning level.

Read `references/delegation-playbook.md` before delegating. For DIRECT work, follow the core rules below without loading the playbook unless its templates are useful.

## Core invariants

- Run only after explicit skill invocation. Keep `allow_implicit_invocation: false`.
- Main owns context, decisions, implementation by default, validation, and the final response.
- Use **0–2 native subagents by default**. Across one `$lunamaxxing` run, never exceed **3 total child sessions** or **3 concurrent children**. Reviewers, retries, and follow-ups all consume this same total budget.
- Do not allow recursive delegation. Tell every subagent not to create another agent.
- Delegate for new information, independent verification, or meaningful parallel progress—not ceremony.
- Every subagent is read-only. **Main Luna Max is the only writer.** Delegation is for investigation and review, never parallel implementation.
- Delegate only when the native runtime can explicitly select **`gpt-5.6-luna` with `xhigh` reasoning** for the child and reliably verify that selection, preferably through returned runtime metadata. A requested override is not proof. If selection cannot be enforced or verified, choose DIRECT. **Unverified xhigh = no delegation.**
- Never create a separate process to obtain a preferred child model.
- Preserve repository instructions, user work, authorization boundaries, and evidence integrity.

## Select one route

### DIRECT

Use no subagent when the task is small, deterministic, low risk, or not meaningfully divisible.

`Main -> inspect -> decide -> implement or answer -> verify`

### DELEGATED

Use 1–2 focused, verified Luna xhigh subagents when isolated investigation, an alternative, or independent review can materially improve the result.

`Main -> focused receipts -> synthesize -> implement -> verify`

### FANOUT

Use up to 3 verified Luna xhigh subagents only when the task has genuinely independent workstreams, such as a repository-wide audit or complex cross-system investigation. The limit is 3 total sessions for the whole run, not a refillable concurrency window. Difficulty alone is insufficient.

`Main -> independent specialist receipts -> deduplicate and verify -> decide -> implement -> verify`

## Delegate deliberately

Before spawning, confirm both: **Will isolated context produce new evidence, independent validation, or useful parallel progress?** and **Can this child be selected and verified as Luna xhigh?** If either answer is no—or the user forbids subagents—choose DIRECT.

Give each subagent a narrow task packet from the playbook. Divide work by information lane—architecture, runtime flow, regressions, tests, or hypothesis challenge—instead of asking several agents to implement the same change. Two independent investigators may examine the same uncertain bug when reasoning diversity is the point.

Treat every receipt as a claim, not proof. Main verifies critical findings using the cheapest decisive check before acting.

## Execute proportionally

1. Inspect primary artifacts and applicable instructions.
2. Separate observed facts, supported inferences, assumptions, and unknowns.
3. Select DIRECT, DELEGATED, or FANOUT.
4. If delegating, assign bounded scopes and collect structured receipts.
5. Synthesize evidence and choose one coherent approach.
6. Implement only in main. Children remain read-only investigators or reviewers.
7. Run targeted checks, inspect actual behavior or artifacts when relevant, and check nearby regressions.
8. Iterate only for a failed acceptance criterion, new material evidence, or a regression.

Do not require long briefs, three alternatives, pre-mortems, skeptic passes, or elaborate confidence reports for every task. Apply them only when uncertainty or impact makes them useful.

## Report

Lead with the user outcome. Summarize decisive evidence, changes, validation, and remaining risk. Include orchestration metadata only when useful, for example:

```text
Route: DELEGATED
Subagents: 2 verified native Luna xhigh investigators
Validation: passed
```

Never claim Luna becomes intrinsically equivalent to a stronger model. State only that focused delegation, evidence, synthesis, and verification improve the probability of a strong result.
