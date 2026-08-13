[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "Assertion failed: $Message" }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillRoot = Join-Path (Join-Path $repoRoot 'skills') 'lunamaxxing'
$skill = Get-Content -Raw -Encoding UTF8 (Join-Path $skillRoot 'SKILL.md')
$metadata = Get-Content -Raw -Encoding UTF8 (Join-Path (Join-Path $skillRoot 'agents') 'openai.yaml')
$playbook = Get-Content -Raw -Encoding UTF8 (Join-Path (Join-Path $skillRoot 'references') 'delegation-playbook.md')
$directDeep = Get-Content -Raw -Encoding UTF8 (Join-Path (Join-Path $skillRoot 'references') 'direct-deep-playbook.md')
$readmeEn = Get-Content -Raw -Encoding UTF8 (Join-Path $repoRoot 'README.md')
$readmeTr = Get-Content -Raw -Encoding UTF8 (Join-Path $repoRoot 'README.tr.md')
$workflow = Get-Content -Raw -Encoding UTF8 (Join-Path (Join-Path (Join-Path $repoRoot '.github') 'workflows') 'test.yml')

Assert-True ($metadata -match 'allow_implicit_invocation:\s*false') 'implicit invocation must stay disabled'
Assert-True ($skill -match 'explicitly invokes \$lunamaxxing') 'explicit invocation trigger must be documented'
Assert-True ($skill -match 'Do not invoke merely') 'negative trigger boundary must be documented'
Assert-True ($skill -match '### DIRECT' -and $skill -match '### DELEGATED' -and $skill -match '### FANOUT') 'all routes must exist'
Assert-True ($skill -match '3 total child sessions') 'hard total child limit must be three'
Assert-True ($skill -match '3 concurrent children') 'concurrency limit must be three'
Assert-True ($skill -match 'Every spawn and follow-up turn consumes this same total budget, including reviewers and retries') 'all child calls must consume the total budget'
Assert-True ($skill -match 'Do not allow recursive delegation') 'recursive delegation must be prohibited'
Assert-True ($skill -match 'Every subagent is read-only') 'all children must be read-only'
Assert-True ($skill -match 'Main Luna Max is the only writer') 'main must be the only writer'
Assert-True ($skill -match 'Unverified xhigh = no delegation') 'strict xhigh fallback must be explicit'
Assert-True ($skill -match 'requested override is not proof') 'requested xhigh must not count as verification'
Assert-True ($skill -match 'DIRECT does not mean shallow') 'DIRECT must not imply shallow execution'
Assert-True ($skill -match 'Choose \*\*route\*\* and \*\*depth\*\* separately') 'route and depth must be separate decisions'
Assert-True ($skill -match 'DIRECT with the original depth preserved') 'strict xhigh fallback must preserve task depth'
Assert-True ($skill -match 'direct-deep-playbook\.md') 'substantial DIRECT fallback must load its playbook'

foreach ($rule in @('No delegation does not mean reduced work', 'Define the finish line', 'Create bounded milestones', 'Prove the core path early', 'Validate proportionally', 'Perform a fresh final review', 'local web games')) {
    Assert-True ($directDeep.Contains($rule)) "DIRECT-DEEP playbook missing: $rule"
}

foreach ($field in @('GOAL:', 'SCOPE:', 'RELEVANT_PATHS:', 'KNOWN_EVIDENCE:', 'QUESTION_TO_ANSWER:', 'CONSTRAINTS:', 'FORBIDDEN_ACTIONS:', 'EXPECTED_OUTPUT:')) {
    Assert-True ($playbook.Contains($field)) "task packet missing $field"
}
foreach ($field in @('STATUS:', 'SUMMARY:', 'FINDINGS:', 'EVIDENCE:', 'CONFIDENCE:', 'RISKS:', 'RECOMMENDED_NEXT_ACTION:')) {
    Assert-True ($playbook.Contains($field)) "receipt missing $field"
}
foreach ($rule in @('DONE`', 'DONE_WITH_CONCERNS`', 'NEEDS_CONTEXT`', 'BLOCKED` or failed', 'one bounded follow-up', 'automatic replacement child', 'completed child as closed')) {
    Assert-True ($playbook.Contains($rule)) "child lifecycle missing: $rule"
}
Assert-True ($playbook -match 'follow-up consumes one unit of the same total child-session budget') 'bounded follow-up must consume the total budget'
foreach ($rule in @('Native subagent capability is available', 'explicitly selected as `gpt-5.6-luna` with `xhigh` reasoning', 'returned runtime metadata', 'do not spawn and continue DIRECT')) {
    Assert-True ($playbook.Contains($rule)) "xhigh verification contract missing: $rule"
}

$scriptFiles = @(Get-ChildItem -File -Recurse -ErrorAction SilentlyContinue (Join-Path $skillRoot 'scripts'))
Assert-True ($scriptFiles.Count -eq 0) 'obsolete process scripts must be absent'

$textExtensions = @('.md', '.json', '.ps1', '.yaml', '.yml', '.toml')
$repoTextFiles = @(Get-ChildItem -File -Recurse -LiteralPath $repoRoot | Where-Object {
    $_.FullName -notmatch '[\\/]\.git[\\/]' -and $textExtensions -contains $_.Extension.ToLowerInvariant()
})
$repoText = ($repoTextFiles | ForEach-Object { Get-Content -Raw -Encoding UTF8 -LiteralPath $_.FullName }) -join "`n"
$legacyTerms = @(
    ('codex ' + 'exec'), ('Dry' + 'Run'), ('OutputLast' + 'Message'),
    ('LUNAMAXXING_' + 'WORKER_ACTIVE'), ('invoke-' + 'lunamaxxing'),
    ('pinned Luna Max ' + 'worker'), ('external ' + 'worker')
)
foreach ($term in $legacyTerms) {
    Assert-True (-not $repoText.Contains($term)) "obsolete architecture term remains: $term"
}

$oldWriterTerms = @(
    ('parallel ' + 'implementation'), ('disjoint file ' + 'ownership'),
    ('delegated ' + 'writer'), ('parallel ' + 'coding')
)
foreach ($term in $oldWriterTerms) {
    Assert-True (-not $skill.Contains($term)) "old writer policy remains in SKILL.md: $term"
    Assert-True (-not $playbook.Contains($term)) "old writer policy remains in playbook: $term"
}

foreach ($doc in @($readmeEn, $readmeTr)) {
    foreach ($term in @('explicit', 'DIRECT', 'DELEGATED', 'FANOUT', 'xhigh', 'read-only', '3 total', 'DEEP')) {
        Assert-True ($doc.Contains($term)) "README missing shared behavior: $term"
    }
}
Assert-True ($readmeEn -match 'Main.*only writer') 'English README must document main-only writing'
Assert-True ($readmeTr -match 'Main.*tek writer') 'Turkish README must document main-only writing'
Assert-True ($workflow -match 'evaluate-routing\.ps1') 'CI must run routing evals'

& (Join-Path (Join-Path $repoRoot 'evals') 'evaluate-routing.ps1')

Write-Output 'All LunaMaxxing architecture tests passed.'
