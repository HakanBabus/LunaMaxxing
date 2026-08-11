<div align="center">

# LunaMaxxing

**Quality-first Codex skills built through real use, testing, and iteration.**

[![Codex Skill](https://img.shields.io/badge/Codex-Skill-111827?style=for-the-badge)](https://developers.openai.com/codex/)
[![Status](https://img.shields.io/badge/status-experimental-f59e0b?style=for-the-badge)](#project-status)
[![License: MIT](https://img.shields.io/badge/license-MIT-22c55e?style=for-the-badge)](LICENSE)

[English](README.md) · [Türkçe](README.tr.md) · [Install](#installation) · [How it works](#how-lunamaxxing-works)

</div>

---

**LunaMaxxing** is an adaptive Codex workflow designed to help Luna Max produce stronger results through deliberate framing, evidence gathering, alternative generation, stepwise execution, and explicit verification.

> [!IMPORTANT]
> LunaMaxxing does not claim that Luna becomes intrinsically equivalent to a stronger model. It improves the process around the model so that difficult tasks are less likely to end with a shallow first answer.

## Available skills

| Skill | Purpose | Status |
| --- | --- | --- |
| [`lunamaxxing`](skills/lunamaxxing) | Quality-first analysis, planning, implementation, and verification with adaptive depth | Experimental |

## Why LunaMaxxing?

Cheap reasoning is useful only when the extra work is structured. LunaMaxxing adds guardrails that make longer runs purposeful:

- **Explicit invocation:** it runs only when the user asks for it.
- **Current-session first:** it preserves conversation context by default.
- **Controlled worker dispatch:** a pinned Luna Max CLI worker is started only when explicitly requested.
- **Adaptive depth:** a simple `0–5` score chooses Light, Standard, or Deep reasoning.
- **Bounded iteration:** correction rounds are capped to prevent endless polishing.
- **Authority boundaries:** analysis does not silently become implementation or an external action.
- **Evidence-backed confidence:** more prose cannot raise confidence; stronger evidence can.
- **Task-specific modules:** product, research, debugging, creative work, and visual QA load only when relevant.

## Installation

### Option A — Ask Codex to install it

Use the built-in skill installer:

```text
Use $skill-installer to install lunamaxxing from
https://github.com/HakanBabus/LunaMaxxing/tree/main/skills/lunamaxxing
```

The installed skill becomes available on the next turn.

### Option B — Install with the bundled installer script

```powershell
python "$env:USERPROFILE\.codex\skills\.system\skill-installer\scripts\install-skill-from-github.py" `
  --repo HakanBabus/LunaMaxxing `
  --path skills/lunamaxxing
```

The installer intentionally stops if a skill with the same name already exists.

<details>
<summary><strong>Manual installation</strong></summary>

Clone the repository, then copy the skill folder into your Codex skills directory:

```powershell
git clone https://github.com/HakanBabus/LunaMaxxing.git
Copy-Item -Recurse `
  .\LunaMaxxing\skills\lunamaxxing `
  "$env:USERPROFILE\.codex\skills\lunamaxxing"
```

Start a new Codex turn after installation.

</details>

## Usage

Invoke the skill explicitly:

```text
Use $lunamaxxing to analyze this product problem, choose the strongest direction,
implement it step by step, and verify the result.
```

The skill stays in the current session unless you explicitly request a separate worker:

```text
Use $lunamaxxing in a separate pinned Luna Max CLI worker for this task.
```

<details>
<summary><strong>More example prompts</strong></summary>

```text
Use $lunamaxxing to diagnose this regression before changing any code.
```

```text
Use $lunamaxxing to compare three product directions, select one, implement it,
and validate the user-visible result.
```

```text
Use $lunamaxxing to research this decision, separate facts from inference,
and produce an implementation-ready plan.
```

</details>

## How LunaMaxxing works

1. **Respect authority** — determine whether the request permits analysis, local changes, or external actions.
2. **Select the route** — continue in the current session by default; dispatch only when explicitly requested.
3. **Score the task** — use five simple uncertainty and risk signals to choose the depth.
4. **Frame success** — define the outcome, acceptance criteria, constraints, preserved behavior, and open risks.
5. **Establish evidence** — inspect the real system and test competing explanations.
6. **Explore and decide** — generate materially different directions when the task warrants it.
7. **Execute step by step** — make focused changes and inspect each result.
8. **Verify independently** — test purpose, behavior, artifacts, regressions, and the most damaging plausible failure.
9. **Report confidence** — tie Low, Medium, or High confidence to actual validation evidence.

### Adaptive depth

| Score | Budget | Default correction limit | Typical use |
| ---: | --- | ---: | --- |
| `0–1` | Light | 1 | Localized, deterministic, low-risk work |
| `2–3` | Standard | 2 | Non-trivial work with uncertainty or alternatives |
| `4–5` | Deep | 3 | Ambiguous, cross-cutting, high-risk, or heavily state-dependent work |

The limits are allowances, not targets. The workflow stops early when evidence already supports acceptance.

## Repository structure

```text
LunaMaxxing/
├─ skills/
│  └─ lunamaxxing/
│     ├─ SKILL.md
│     ├─ agents/openai.yaml
│     ├─ references/
│     └─ scripts/
├─ README.md
├─ README.tr.md
├─ CONTRIBUTING.md
└─ LICENSE
```

## Safety and limitations

- The skill is not authority for destructive actions, purchases, credential use, production changes, or scope expansion.
- Model identity is reported only when runtime metadata verifies it or the launcher pins it.
- A separate worker is never created merely to gain more thinking time.
- Some CLI flags and model identifiers may depend on the user's Codex version and account availability.
- The project is experimental; inspect the workflow before using it on high-impact work.

## Project status

The current version is ready for practical testing and public iteration. Planned additions include reproducible example tasks, Luna Max versus LunaMaxxing comparisons, evaluation tables, and visual result graphs.

## Contributing

Issues and focused pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Released under the [MIT License](LICENSE).
