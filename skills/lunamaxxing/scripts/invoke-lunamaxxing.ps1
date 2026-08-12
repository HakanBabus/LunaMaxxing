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
    [switch]$IsolatedConfig,

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
$modulesPath = Join-Path $skillRoot 'references'
$contractPath = Join-Path $modulesPath 'luna-max-contract.md'

$codexCommand = Get-Command codex -ErrorAction SilentlyContinue
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

$routingBlock = @"
# Lunamaxxing Runtime Routing

$workerMarker
PINNED_MODEL=$fixedModel
PINNED_REASONING_EFFORT=$fixedReasoning
LUNAMAXXING_MODULES_DIR=$resolvedModules

This routing block was injected by the launcher before the user task packet. Execute the task directly in this session. Never invoke the lunamaxxing launcher or create another worker. Classify the task and read every matching quality module from LUNAMAXXING_MODULES_DIR before substantive work.
"@

$effectivePrompt = @"
$routingBlock

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
    '-s', $Sandbox
    '-C', $resolvedWorkdir
    '-m', $fixedModel
    '-c', "model_reasoning_effort=$fixedReasoning"
)

if ($IsolatedConfig) {
    $arguments += '--ignore-user-config'
}

if ($Json) {
    $arguments += '--json'
}

$resolvedOutput = $null
$outputDirectoryToCreate = $null
if ($OutputLastMessage) {
    if ([System.IO.Path]::IsPathRooted($OutputLastMessage)) {
        $resolvedOutput = [System.IO.Path]::GetFullPath($OutputLastMessage)
    }
    else {
        $resolvedOutput = [System.IO.Path]::GetFullPath((Join-Path $resolvedWorkdir $OutputLastMessage))
    }
    $outputDirectoryToCreate = Split-Path -Parent $resolvedOutput
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
        TrustedWorkerMarkerCount = ([regex]::Matches($routingBlock, [regex]::Escape($workerMarker))).Count
        UserTaskContainsWorkerMarker = $taskPrompt.Contains($workerMarker)
        SessionMode = 'one-shot-ephemeral'
        Resumable = $false
        IsolatedConfig = [bool]$IsolatedConfig
        UserConfigMode = if ($IsolatedConfig) { 'ignored' } else { 'inherited' }
        OutputLastMessage = $resolvedOutput
        CodexAvailable = ($null -ne $codexCommand)
        Executable = if ($codexCommand) { $codexCommand.Source } else { $null }
        Arguments = $arguments
        ModelSessionStarted = $false
    } | ConvertTo-Json -Depth 4
    return
}

if (-not $codexCommand) {
    throw 'Codex CLI was not found. Install Codex or add the codex executable to PATH before starting a Luna Max worker.'
}

if ($outputDirectoryToCreate -and -not (Test-Path -LiteralPath $outputDirectoryToCreate -PathType Container)) {
    New-Item -ItemType Directory -Path $outputDirectoryToCreate -Force | Out-Null
}

$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $codexCommand.Source
$startInfo.UseShellExecute = $false
$startInfo.RedirectStandardInput = $true
$startInfo.CreateNoWindow = $true

if ($startInfo.PSObject.Properties.Name -contains 'ArgumentList') {
    foreach ($argument in $arguments) {
        [void]$startInfo.ArgumentList.Add([string]$argument)
    }
}
else {
    $quotedArguments = foreach ($argument in $arguments) {
        '"' + ([string]$argument -replace '(\\*)"', '$1$1\\"' -replace '(\\*)$', '$1$1') + '"'
    }
    $startInfo.Arguments = $quotedArguments -join ' '
}

$workerProcess = New-Object System.Diagnostics.Process
$workerProcess.StartInfo = $startInfo
if (-not $workerProcess.Start()) {
    throw 'Luna Max worker process did not start.'
}

$promptBytes = $utf8NoBom.GetBytes($effectivePrompt)
$workerProcess.StandardInput.BaseStream.Write($promptBytes, 0, $promptBytes.Length)
$workerProcess.StandardInput.Close()
$workerProcess.WaitForExit()
$workerExitCode = $workerProcess.ExitCode

if ($workerExitCode -ne 0) {
    throw "Luna Max worker failed with exit code $workerExitCode. Do not fall back to another model or reasoning effort."
}
