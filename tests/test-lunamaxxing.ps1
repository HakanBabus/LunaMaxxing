[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Assert-True {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if (-not $Condition) {
        throw "Assertion failed: $Message"
    }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillRoot = Join-Path (Join-Path $repoRoot 'skills') 'lunamaxxing'
$launcher = Join-Path (Join-Path $skillRoot 'scripts') 'invoke-lunamaxxing.ps1'
$contractPath = Join-Path (Join-Path $skillRoot 'references') 'luna-max-contract.md'
$skillPath = Join-Path $skillRoot 'SKILL.md'
$promptPath = [System.IO.Path]::GetTempFileName()
$marker = 'LUNAMAXXING_WORKER_ACTIVE=true'
$unicodeSample = [string]::Concat(
    [char]0x011f, [char]0x015f, [char]0x0131, [char]0x0130,
    [char]0x00f6, [char]0x00fc, [char]0x2014, [char]0x201c,
    [char]0x201d, [char]0x20ac
)
$prompt = "Unicode prompt: $unicodeSample. $marker"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

try {
    [System.IO.File]::WriteAllText($promptPath, $prompt, $utf8NoBom)

    Push-Location ([System.IO.Path]::GetTempPath())
    try {
        $defaultRun = & $launcher -PromptFile $promptPath -Workdir $repoRoot -Sandbox read-only -DryRun | ConvertFrom-Json
        $isolatedRun = & $launcher -PromptFile $promptPath -Workdir $repoRoot -Sandbox read-only -IsolatedConfig -DryRun | ConvertFrom-Json
    }
    finally {
        Pop-Location
    }

    Assert-True ($defaultRun.Model -eq 'gpt-5.6-luna') 'model must stay pinned to gpt-5.6-luna'
    Assert-True ($defaultRun.Reasoning -eq 'max') 'reasoning effort must stay pinned to max'
    Assert-True ($defaultRun.TaskPromptCharacters -eq $prompt.Length) 'UTF-8 prompt characters must be preserved'
    Assert-True ($defaultRun.WorkerMarker -eq $marker) 'trusted worker marker must be present'
    Assert-True ($defaultRun.TrustedWorkerMarkerCount -eq 1) 'routing block must contain exactly one trusted marker'
    Assert-True ([bool]$defaultRun.UserTaskContainsWorkerMarker) 'marker-like user text must remain distinguishable from the routing marker'
    Assert-True ($defaultRun.SessionMode -eq 'one-shot-ephemeral') 'worker must be declared one-shot'
    Assert-True (-not [bool]$defaultRun.Resumable) 'ephemeral worker must not claim resumability'
    Assert-True ($defaultRun.UserConfigMode -eq 'inherited') 'user config must be inherited by default'
    Assert-True (-not ($defaultRun.Arguments -contains '--ignore-user-config')) 'default arguments must preserve user config'
    Assert-True ($defaultRun.Arguments -contains '--ephemeral') 'worker must remain ephemeral'
    Assert-True ($isolatedRun.UserConfigMode -eq 'ignored') 'isolated mode must report ignored user config'
    Assert-True ($isolatedRun.Arguments -contains '--ignore-user-config') 'isolated mode must add the CLI isolation flag'
    Assert-True ([System.IO.Path]::IsPathRooted($defaultRun.ContractPath)) 'contract path must be absolute'
    Assert-True ([System.IO.Path]::IsPathRooted($defaultRun.ModulesDirectory)) 'module directory must be absolute'
    Assert-True (-not [bool]$defaultRun.ModelSessionStarted) 'dry-run must never start a model session'

    $contract = Get-Content -Raw -Encoding UTF8 -LiteralPath $contractPath
    $skill = Get-Content -Raw -Encoding UTF8 -LiteralPath $skillPath
    Assert-True ($contract -match 'Start at \*\*0\*\*') 'contract must include the scoring algorithm'
    Assert-True (($contract -match 'Light') -and ($contract -match 'Standard') -and ($contract -match 'Deep')) 'contract must include all budget bands'
    Assert-True (($contract -match 'Light \| 1 correction round') -and ($contract -match 'Standard \| 2 correction rounds') -and ($contract -match 'Deep \| 3 correction rounds')) 'contract must include all correction limits'
    Assert-True ($skill -match 'single source of truth') 'SKILL.md must delegate budget rules to the contract'
    Assert-True (-not ($skill -match 'resumable worker')) 'SKILL.md must not claim that an ephemeral worker is resumable'

    Write-Output 'All LunaMaxxing tests passed.'
}
finally {
    if (Test-Path -LiteralPath $promptPath) {
        Remove-Item -LiteralPath $promptPath -Force
    }
}
