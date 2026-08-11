# Debugging Root-Cause Protocol

Read this module for bugs, regressions, unexplained behavior, performance failures, or UX symptoms whose cause is not already demonstrated.

## Build the hypothesis tree

Write the observed symptom without embedding a diagnosis. Create 2–4 materially different hypotheses across relevant layers, such as:

- presentation, layout, CSS, or rendering;
- state, lifecycle, concurrency, or data flow;
- API, persistence, parsing, or environment;
- interaction model, user expectation, or product logic.

For each hypothesis record:

| Field | Requirement |
|---|---|
| Supporting evidence | Observation expected if the hypothesis is true |
| Falsifying evidence | Observation that would substantially weaken it |
| Cheapest discriminating check | Smallest safe test that separates it from alternatives |
| Impact if true | Scope of the required correction and regression risk |

Test high-information, low-cost checks first. Update probabilities from evidence; do not keep favored hypotheses alive through excuses.

## Fix the demonstrated cause

- Establish a reproducible baseline or minimal failing case when practical.
- Trace the relevant real execution path, not only nearby code.
- Prefer the smallest correction that addresses the demonstrated cause.
- Do not apply a visual patch to a state or interaction problem.
- Add a regression check at the lowest reliable layer and validate the user-visible path when impact reaches it.
- If the cause remains uncertain, state the leading hypothesis and uncertainty rather than presenting a speculative fix as proven.
