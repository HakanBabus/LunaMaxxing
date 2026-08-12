[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Text')]
    [ValidateNotNullOrEmpty()]
    [string]$Prompt,

    [Parameter(Mandatory = $true, ParameterSetName = 'File')]
    [ValidateNotNullOrEmpty()]
    [string]$PromptFile,

    [Parameter()]
    [ValidateSet('read-only', 'workspace-write')]
    [string]$Sandbox = 'read-only',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Workdir = (Get-Location).Path,

    [Parameter()]
    [string]$OutputLastMessage,

    [Parameter()]
    [switch]$Json,

    [Parameter()]
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$OutputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom

$fixedModel = 'gpt-5.6-luna'
$fixedReasoning = 'max'
$workerMarker = 'LUNAMAXXING_WORKER_ACTIVE=true'
$skillRoot = Split-Path -Parent $PSScriptRoot
$contractPath = Join-Path $skillRoot 'references\luna-max-contract.md'
$modulesPath = Join-Path $skillRoot 'references'

$codexCommand = Get-Command codex -ErrorAction Stop
$resolvedWorkdir = (Resolve-Path -LiteralPath $Workdir -ErrorAction Stop).Path
$resolvedContract = (Resolve-Path -LiteralPath $contractPath -ErrorAction Stop).Path
$resolvedModules = (Resolve-Path -LiteralPath $modulesPath -ErrorAction Stop).Path
$contract = Get-Content -Raw -Encoding UTF8 -LiteralPath $resolvedContract

if ($PSCmdlet.ParameterSetName -eq 'File') {
    $resolvedPromptFile = (Resolve-Path -LiteralPath $PromptFile -ErrorAction Stop).Path
    $taskPrompt = Get-Content -Raw -Encoding UTF8 -LiteralPath $resolvedPromptFile
    $promptSource = $resolvedPromptFile
}
else {
    $taskPrompt = $Prompt
    $promptSource = 'inline'
}

if ([string]::IsNullOrWhiteSpace($taskPrompt)) {
    throw 'Task prompt must contain non-whitespace text.'
}

$effectivePrompt = @"
# Lunamaxxing Runtime Routing

$workerMarker
PINNED_MODEL=$fixedModel
PINNED_REASONING_EFFORT=$fixedReasoning
LUNAMAXXING_MODULES_DIR=$resolvedModules

This routing block was injected by the launcher before the user task packet. Execute the task directly in this session. Never invoke the lunamaxxing launcher or create another worker. Classify the task and read every matching quality module from LUNAMAXXING_MODULES_DIR before substantive work.

---

$contract

---

# User Task Packet

$taskPrompt
"@

$arguments = @(
    'exec'
    '--ephemeral'
    '--skip-git-repo-check'
    '--ignore-user-config'
    '-s', $Sandbox
    '-C', $resolvedWorkdir
    '-m', $fixedModel
    '-c', "model_reasoning_effort=$fixedReasoning"
)

if ($Json) {
    $arguments += '--json'
}

$resolvedOutput = $null
if ($OutputLastMessage) {
    $outputParent = Split-Path -Parent $OutputLastMessage
    if ($outputParent) {
        $resolvedOutputParent = (Resolve-Path -LiteralPath $outputParent -ErrorAction Stop).Path
        $resolvedOutput = Join-Path $resolvedOutputParent (Split-Path -Leaf $OutputLastMessage)
    }
    else {
        $resolvedOutput = Join-Path $resolvedWorkdir $OutputLastMessage
    }
    $arguments += @('-o', $resolvedOutput)
}

$arguments += '-'

if ($DryRun) {
    [pscustomobject]@{
        Model = $fixedModel
        Reasoning = $fixedReasoning
        WorkerMarker = $workerMarker
        RequestedSandbox = $Sandbox
        Workdir = $resolvedWorkdir
        PromptSource = $promptSource
        ContractPath = $resolvedContract
        ModulesDirectory = $resolvedModules
        TaskPromptCharacters = $taskPrompt.Length
        EffectivePromptCharacters = $effectivePrompt.Length
        OutputLastMessage = $resolvedOutput
        Executable = $codexCommand.Source
        Arguments = $arguments
        ModelSessionStarted = $false
    } | ConvertTo-Json -Depth 4
    return
}

$effectivePrompt | & $codexCommand.Source @arguments
$workerExitCode = $LASTEXITCODE

if ($workerExitCode -ne 0) {
    throw "Luna Max worker failed with exit code $workerExitCode. Do not fall back to another model or reasoning effort."
}
