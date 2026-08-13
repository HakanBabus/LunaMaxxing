[CmdletBinding()]
param(
    [string]$ScenariosPath = (Join-Path $PSScriptRoot 'routing-scenarios.json')
)

$ErrorActionPreference = 'Stop'

function Get-LunaMaxxingRoute {
    param([Parameter(Mandatory = $true)]$Scenario)

    $depth = if ([bool]$Scenario.localized_deterministic) {
        'LIGHT'
    } elseif ([bool]$Scenario.multi_milestone -or [bool]$Scenario.cross_system -or [bool]$Scenario.high_uncertainty_or_impact) {
        'DEEP'
    } else {
        'STANDARD'
    }

    $verifiedXhigh = [bool]$Scenario.native_subagents_available -and
        [bool]$Scenario.luna_xhigh_selectable -and
        [bool]$Scenario.luna_xhigh_verifiable

    $workstreams = [Math]::Max(1, [int]$Scenario.independent_workstreams)
    $naturalRoute = if ([bool]$Scenario.user_forbids_subagents -or -not [bool]$Scenario.delegation_adds_value) {
        'DIRECT'
    } elseif ($workstreams -ge 3) {
        'FANOUT'
    } else {
        'DELEGATED'
    }

    if ($naturalRoute -eq 'DIRECT') {
        return [pscustomobject]@{ Route = 'DIRECT'; NaturalRoute = 'DIRECT'; Depth = $depth; Fallback = 'NONE'; MaxChildren = 0 }
    }

    if (-not $verifiedXhigh) {
        return [pscustomobject]@{ Route = 'DIRECT'; NaturalRoute = $naturalRoute; Depth = $depth; Fallback = 'UNVERIFIED_XHIGH'; MaxChildren = 0 }
    }

    $maxChildren = if ($naturalRoute -eq 'FANOUT') { 3 } else { [Math]::Min(2, $workstreams) }
    return [pscustomobject]@{ Route = $naturalRoute; NaturalRoute = $naturalRoute; Depth = $depth; Fallback = 'NONE'; MaxChildren = $maxChildren }
}

$suite = Get-Content -Raw -Encoding UTF8 -LiteralPath $ScenariosPath | ConvertFrom-Json
$failures = @()
$results = foreach ($scenario in $suite.scenarios) {
    $actual = Get-LunaMaxxingRoute -Scenario $scenario
    $passed = $actual.Route -eq $scenario.expected_route -and
        $actual.NaturalRoute -eq $scenario.expected_natural_route -and
        $actual.Depth -eq $scenario.expected_depth -and
        $actual.Fallback -eq $scenario.expected_fallback -and
        $actual.MaxChildren -eq [int]$scenario.expected_max_children -and
        $scenario.writer_policy -eq 'main_only'

    if (-not $passed) {
        $failures += $scenario.id
    }

    [pscustomobject]@{
        Id = $scenario.id
        ExpectedRoute = $scenario.expected_route
        ActualRoute = $actual.Route
        NaturalRoute = $actual.NaturalRoute
        Depth = $actual.Depth
        Fallback = $actual.Fallback
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
