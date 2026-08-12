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
$readmeEn = Get-Content -Raw -Encoding UTF8 (Join-Path $repoRoot 'README.md')
$readmeTr = Get-Content -Raw -Encoding UTF8 (Join-Path $repoRoot 'README.tr.md')
$workflow = Get-Content -Raw -Encoding UTF8 (Join-Path (Join-Path (Join-Path $repoRoot '.github') 'workflows') 'test.yml')
$scenarios = Get-Content -Raw -Encoding UTF8 (Join-Path (Join-Path $repoRoot 'evals') 'routing-scenarios.json') | ConvertFrom-Json
$allProjectText = $skill + $metadata + $playbook + $readmeEn + $readmeTr + $workflow

Assert-True ($metadata -match 'allow_implicit_invocation:\s*false') 'implicit invocation must stay disabled'
Assert-True ($skill -match 'explicitly invokes \$lunamaxxing') 'explicit invocation trigger must be documented'
Assert-True ($skill -match 'Do not invoke merely') 'negative trigger boundary must be documented'
Assert-True ($skill -match '### DIRECT' -and $skill -match '### DELEGATED' -and $skill -match '### FANOUT') 'all routes must exist'
Assert-True ($skill -match 'never exceed 3 concurrent subagents') 'hard concurrency limit must be three'
Assert-True ($skill -match 'Do not allow recursive delegation') 'recursive delegation must be prohibited'
Assert-True ($skill -match 'Main is the default writer') 'main must be the default writer'
Assert-True ($skill -match 'overlapping files have exactly one writer') 'overlapping writer ownership must be prohibited'
Assert-True ($skill -match 'gpt-5\.6-luna.*xhigh') 'preferred child routing must be documented'
Assert-True ($skill -match 'Otherwise use the native capacity available or skip delegation') 'safe model fallback must be documented'

foreach ($field in @('GOAL:', 'SCOPE:', 'RELEVANT_PATHS:', 'KNOWN_EVIDENCE:', 'QUESTION_TO_ANSWER:', 'CONSTRAINTS:', 'FORBIDDEN_ACTIONS:', 'EXPECTED_OUTPUT:')) {
    Assert-True ($playbook.Contains($field)) "task packet missing $field"
}
foreach ($field in @('STATUS:', 'SUMMARY:', 'FINDINGS:', 'EVIDENCE:', 'CONFIDENCE:', 'RISKS:', 'RECOMMENDED_NEXT_ACTION:')) {
    Assert-True ($playbook.Contains($field)) "receipt missing $field"
}

$scriptFiles = @(Get-ChildItem -File -Recurse -ErrorAction SilentlyContinue (Join-Path $skillRoot 'scripts'))
Assert-True ($scriptFiles.Count -eq 0) 'obsolete script files must be absent'
$deprecatedTerms = @(
    ('codex ' + 'exec'), ('Dry' + 'Run'), ('OutputLast' + 'Message'),
    ('LUNAMAXXING_' + 'WORKER_ACTIVE'), ('invoke-' + 'lunamaxxing'),
    ('pinned Luna Max ' + 'worker'), ('external ' + 'worker')
)
foreach ($term in $deprecatedTerms) {
    Assert-True (-not $allProjectText.Contains($term)) "obsolete architecture term remains: $term"
}

$expectedRoutes = @{ tiny_typo = 'DIRECT'; unclear_state_bug = 'DELEGATED'; repository_wide_audit = 'FANOUT' }
foreach ($scenario in $scenarios.scenarios) {
    Assert-True ($scenario.expected_route -eq $expectedRoutes[$scenario.id]) "unexpected route for $($scenario.id)"
    Assert-True ($scenario.expected_max_subagents -le 3) "subagent limit exceeded for $($scenario.id)"
    Assert-True ($scenario.writer_policy -eq 'main_default') "writer policy mismatch for $($scenario.id)"
}

foreach ($doc in @($readmeEn, $readmeTr)) {
    foreach ($term in @('explicit', 'DIRECT', 'DELEGATED', 'FANOUT', 'xhigh')) {
        Assert-True ($doc.Contains($term)) "README missing shared behavior: $term"
    }
}
Assert-True ($readmeEn -match 'maximum 3') 'English README must document the hard limit'
Assert-True ($readmeTr -match '3 subagent') 'Turkish README must document the hard limit'

Write-Output 'All LunaMaxxing architecture tests passed.'
