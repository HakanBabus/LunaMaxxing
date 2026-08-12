# Contributing

Thanks for helping improve these Codex skills.

## Before opening a pull request

1. Keep each skill self-contained under `skills/<skill-name>/`.
2. Keep `SKILL.md` focused on instructions the agent actually needs.
3. Put detailed, conditionally loaded guidance in `references/`.
4. Test scripts directly and run the skill validator when available.
5. Do not include credentials, private paths, generated output, or user data.
6. Explain the behavior change and the evidence used to validate it.

Small, focused pull requests are easiest to review.

## Tests

Run the deterministic launcher and contract suite from the repository root:

```powershell
pwsh -NoProfile -File ./tests/test-lunamaxxing.ps1
```

On Windows without PowerShell 7, use Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\test-lunamaxxing.ps1
```

The same suite runs on Windows and Ubuntu for every push and pull request.
