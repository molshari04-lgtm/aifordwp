<#
.SYNOPSIS
Explained entry point for the Floor 6 deployment evidence collector.

.DESCRIPTION
This companion script documents every collection section before running the maintained production
collector. It passes parameters through unchanged, so the evidence package, DryRun behaviour, and
read-only controls are identical to floor6-deployment-evidence-collection.ps1.

The production collector only reads workstation state. Its evidence-package files, transcript, and
output folder are the only writes it makes; it does not alter applications, services, processes,
registry values, Group Policy, user data, or network configuration.

.PARAMETER DmsName
The product, publisher, service, process, or task name fragment that identifies the Friday DMS
deployment. Use the package's confirmed display or vendor name.

.PARAMETER DeploymentStart
The confirmed start time of Friday's deployment. This defines the file-timestamp correlation window.

.PARAMETER DaysBack
The number of preceding days from which event logs are collected.

.PARAMETER OutputRoot
The parent directory for the timestamped evidence package.

.PARAMETER MaxEventsPerLog
Caps events per log to control collection time and output size.

.PARAMETER MaxFileTimestampResults
Caps DMS-installation files recorded from the deployment correlation window.

.PARAMETER DryRun
Displays the planned evidence package and makes no filesystem writes.

.EXAMPLE
.\floor6-deployment-evidence-collection-annotated.ps1 -DmsName 'Vendor DMS' -DeploymentStart '2026-08-07 13:00' -DryRun
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [string]$DmsName,
    [datetime]$DeploymentStart = (Get-Date).Date.AddDays(-3).AddHours(13),
    [ValidateRange(1, 30)] [int]$DaysBack = 4,
    [string]$OutputRoot = (Join-Path $env:PUBLIC 'Documents\Floor6-Incident-Evidence'),
    [ValidateRange(50, 5000)] [int]$MaxEventsPerLog = 1000,
    [ValidateRange(50, 5000)] [int]$MaxFileTimestampResults = 500,
    [switch]$DryRun
)

# Section 1 - Locate the maintained collector beside this annotated companion.
# Keeping the executable logic in one source prevents a documented copy from becoming stale or
# collecting a different evidence set from the production version.
$collectorPath = Join-Path $PSScriptRoot 'floor6-deployment-evidence-collection.ps1'
if (-not (Test-Path -LiteralPath $collectorPath)) {
    throw "Production collector was not found: $collectorPath"
}

# Section 2 - Explain the collection workflow to the technician before any evidence is read.
# This output is informational only. It does not inspect, modify, or connect to the endpoint.
$collectionSections = @(
    [pscustomobject]@{ Step = 1; Section = 'System identity'; Purpose = 'Records computer, interactive user, domain, OS build, hardware identity, privilege state, last boot, and uptime.' },
    [pscustomobject]@{ Step = 2; Section = 'Installed software'; Purpose = 'Reads uninstall registry records instead of Win32_Product, avoiding MSI repair or consistency activity.' },
    [pscustomobject]@{ Step = 3; Section = 'DMS match'; Purpose = 'Filters installed software by the supplied DMS name to identify deployed version, publisher, and install location.' },
    [pscustomobject]@{ Step = 4; Section = 'Startup applications'; Purpose = 'Reads machine/user Run keys and startup commands for sign-in load and deployment persistence evidence.' },
    [pscustomobject]@{ Step = 5; Section = 'Scheduled tasks'; Purpose = 'Records task metadata and state to identify deployment tasks or jobs that run at logon.' },
    [pscustomobject]@{ Step = 6; Section = 'Running processes'; Purpose = 'Snapshots process names, paths, start time, memory working set, and cumulative CPU time.' },
    [pscustomobject]@{ Step = 7; Section = 'Performance'; Purpose = 'Samples total CPU, memory, and fixed-disk utilization without changing any workload.' },
    [pscustomobject]@{ Step = 8; Section = 'DMS services'; Purpose = 'Finds only services whose metadata matches the DMS name, then records configuration and state.' },
    [pscustomobject]@{ Step = 9; Section = 'Event and logon evidence'; Purpose = 'Collects a bounded Application, System, Security, and Group Policy event window, then extracts authentication-relevant events.' },
    [pscustomobject]@{ Step = 10; Section = 'Group Policy'; Purpose = 'Runs the read-only gpresult report to show policies applied to the collection context.' },
    [pscustomobject]@{ Step = 11; Section = 'Profile and redirection'; Purpose = 'Records profile state, temporary-profile indicators, Desktop/Documents redirection, and OneDrive account metadata.' },
    [pscustomobject]@{ Step = 12; Section = 'Desktop and shortcuts'; Purpose = 'Verifies current and public desktop paths, then inventories shortcut files and timestamps.' },
    [pscustomobject]@{ Step = 13; Section = 'Network and domain'; Purpose = 'Records adapters, addressing, DNS, routes, domain membership, and read-only domain-controller discovery.' },
    [pscustomobject]@{ Step = 14; Section = 'Deployment file timestamps'; Purpose = 'Limits a scan to matched DMS installation paths and records files changed in the deployment window.' },
    [pscustomobject]@{ Step = 15; Section = 'Evidence completion'; Purpose = 'Writes collection errors, a timestamped summary/manifest, and a PowerShell transcript to the evidence folder.' }
)

# Section 3 - Display the planned evidence steps so Service Desk can confirm scope before the run.
# In DryRun mode this is the only collection-related output; the delegated collector creates no files.
Write-Host 'Floor 6 deployment evidence collection - annotated workflow' -ForegroundColor Cyan
$collectionSections | Format-Table -AutoSize -Wrap

# Section 4 - Build the parameter set explicitly.
# No parameter here changes endpoint configuration; all values only constrain what the collector reads
# and where it writes its own evidence package.
$collectorParameters = @{
    DmsName                 = $DmsName
    DeploymentStart         = $DeploymentStart
    DaysBack                = $DaysBack
    OutputRoot              = $OutputRoot
    MaxEventsPerLog         = $MaxEventsPerLog
    MaxFileTimestampResults = $MaxFileTimestampResults
}
if ($DryRun) {
    $collectorParameters.DryRun = $true
}

# Section 5 - Run the production collector.
# It handles transcript creation, per-section error recording, structured JSON/CSV output, and final
# cleanup. Errors from an individual evidence source are recorded in CollectionErrors.json so later
# sections can still complete whenever possible.
& $collectorPath @collectorParameters