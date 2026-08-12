[CmdletBinding()]
param(
    [string]$ScenariosPath = (Join-Path $PSScriptRoot 'routing-scenarios.json')
)

$ErrorActionPreference = 'Stop'

function Get-LunaMaxxingRoute {
    param([Parameter(Mandatory = $true)]$Scenario)

    $verifiedXhigh = [bool]$Scenario.native_subagents_available -and
        [bool]$Scenario.luna_xhigh_selectable -and
        [bool]$Scenario.luna_xhigh_verifiable

    if (-not $verifiedXhigh -or [bool]$Scenario.user_forbids_subagents -or -not [bool]$Scenario.delegation_adds_value) {
        return [pscustomobject]@{ Route = 'DIRECT'; MaxChildren = 0 }
    }

    $workstreams = [Math]::Max(1, [int]$Scenario.independent_workstreams)
    if ($workstreams -ge 3) {
        return [pscustomobject]@{ Route = 'FANOUT'; MaxChildren = 3 }
    }

    return [pscustomobject]@{ Route = 'DELEGATED'; MaxChildren = [Math]::Min(2, $workstreams) }
}

$suite = Get-Content -Raw -Encoding UTF8 -LiteralPath $ScenariosPath | ConvertFrom-Json
$failures = @()
$results = foreach ($scenario in $suite.scenarios) {
    $actual = Get-LunaMaxxingRoute -Scenario $scenario
    $passed = $actual.Route -eq $scenario.expected_route -and
        $actual.MaxChildren -eq [int]$scenario.expected_max_children -and
        $scenario.writer_policy -eq 'main_only'

    if (-not $passed) {
        $failures += $scenario.id
    }

    [pscustomobject]@{
        Id = $scenario.id
        ExpectedRoute = $scenario.expected_route
        ActualRoute = $actual.Route
        ExpectedMaxChildren = [int]$scenario.expected_max_children
        ActualMaxChildren = $actual.MaxChildren
        Passed = $passed
    }
}

$results | Format-Table -AutoSize
if ($failures.Count -gt 0) {
    throw "Routing eval failures: $($failures -join ', ')"
}

Write-Output "Routing evals passed: $($results.Count)/$($results.Count)."
