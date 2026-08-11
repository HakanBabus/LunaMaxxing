# Visual QA Protocol

Read this module for any user-visible interface change. Source review and a passing build are insufficient; inspect the rendered result whenever the environment permits.

## Establish comparison evidence

Capture or inspect the relevant before state. Define the primary viewport, important secondary viewport, user state, content state, and interaction path. After implementation, inspect the same conditions so the comparison is meaningful.

## Run the four validation classes

1. **Purpose:** Does the change improve the intended task, comprehension, or decision?
2. **Behavior:** Do controls, selection, focus, errors, loading, empty states, and recovery work?
3. **Visual:** Inspect hierarchy, clipping, overlap, alignment, density, contrast, state styling, and consistency in the real render.
4. **Regression:** Check neighboring surfaces, preserved workflows, responsive sizes, long text or localization, keyboard access, and performance proportionally.

## Golden-path scenarios

Select those relevant to the product and add task-specific cases:

- Can a first-time user discover the primary action?
- Can the user recover after selecting or clicking the wrong object?
- Does the primary control remain reachable on a narrow screen?
- Do long translated labels wrap or truncate safely?
- Do related views keep selection and state synchronized?
- Are hover, focus, selected, disabled, loading, empty, and error states distinguishable?
- Does repeated use preserve context and avoid unexpected resets?

Record viewport and state coverage. If rendering or interaction testing is unavailable, mark visual or behavioral validation as unsupported and lower confidence; never infer it from code alone.
