# Floor 6 Deployment Evidence Collection

## 1. Investigation Objective

**Hypothesis tested:** the Friday afternoon document management system (DMS) deployment introduced an endpoint-side condition that caused slow or failed logons, poor workstation performance, missing desktop shortcuts, or unexpected access presentation on Floor 6. This remains a working hypothesis, not a confirmed cause.

The collection correlates the deployment window with local software installation records, DMS services and files, startup/task state, resource use, sign-in and Group Policy events, profile and desktop redirection, and network/domain state. It does not determine whether a user was authorized to view a matter; the reported Copilot result needs separate Microsoft 365 audit, Copilot, SharePoint, and DMS authorization evidence.

Supportive findings include a DMS install, file change, service/task activation, or application error beginning in the Friday window and recurring on affected endpoints; a common sign-in, profile, policy, or resource fault naming the DMS/deployment component; or a desktop/OneDrive/folder-redirection state that changed at the same time. The theory is weakened if the DMS state is normal and the evidence instead shows an independent identity, domain-controller, DNS, profile, storage, or hardware fault predating deployment.

Run the production collector elevated where permitted. It is read-only with respect to the workstation: its only writes are the evidence package, transcript, JSON, and CSV files. Supply the **confirmed** deployment time rather than relying on the default example.

```powershell
.\floor6-deployment-evidence-collection.ps1 `
  -DmsName 'Vendor DMS Product Name' `
  -DeploymentStart '2026-08-07 13:00' `
  -DaysBack 4
```

Validate parameters without creating files:

```powershell
.\floor6-deployment-evidence-collection.ps1 -DmsName 'Vendor DMS Product Name' -DryRun
```

## 2. AI-Generated First Draft Script

This is a plausible AI-generated draft. It is deliberately retained for review and must not be used in production.

```powershell
<#
.SYNOPSIS
Collects basic DMS deployment evidence.
.PARAMETER DmsName
Name of the document management application.
.PARAMETER OutputPath
Folder for collected files.
.PARAMETER DryRun
Displays the requested collection without creating output.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$DmsName,
    [string]$OutputPath = 'C:\Temp\Floor6Evidence',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
if ($DryRun) { Write-Host "Would collect $DmsName to $OutputPath"; return }
try {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    $system = Get-CimInstance Win32_OperatingSystem
    $computer = Get-CimInstance Win32_ComputerSystem
    [pscustomobject]@{ Computer = $env:COMPUTERNAME; User = $computer.UserName; OS = $system.Caption; LastBoot = $system.LastBootUpTime } |
        ConvertTo-Json | Set-Content "$OutputPath\SystemInfo.json"
    # Not approved: this can trigger MSI consistency checks.
    Get-CimInstance Win32_Product | Select-Object Name, Version, InstallDate |
        Export-Csv "$OutputPath\InstalledSoftware.csv" -NoTypeInformation
    Get-Process | Select-Object ProcessName, Id, CPU, WorkingSet64 |
        Export-Csv "$OutputPath\Processes.csv" -NoTypeInformation
    Get-Service | Export-Csv "$OutputPath\Services.csv" -NoTypeInformation
    Get-WinEvent -LogName System -MaxEvents 100 | Select-Object TimeCreated, Id, ProviderName, Message |
        Export-Csv "$OutputPath\EventLogs.csv" -NoTypeInformation
    Get-ChildItem "$env:USERPROFILE\Desktop" -Filter '*.lnk' | Select-Object FullName, LastWriteTime |
        Export-Csv "$OutputPath\DesktopShortcuts.csv" -NoTypeInformation
    Get-DnsClientServerAddress | ConvertTo-Json | Set-Content "$OutputPath\NetworkInfo.json"
}
catch { $_ | Out-File "$OutputPath\Errors.txt"; throw }
```

## 3. Human Review of AI Draft

| Review area | Problem | Operational consequence |
|---|---|---|
| Installed software | Uses `Win32_Product`. | Querying it can trigger Windows Installer repair/consistency activity, violating read-only collection and adding endpoint load. |
| DMS correlation | Does not use DMS name or deployment time after accepting the parameter. | It cannot directly test the stated hypothesis. |
| Event evidence | Collects only 100 System events, with no time boundary, Security/Application/Group Policy records, filtering, or collection-error record. | It likely misses logon failures, crashes, policy processing, and the relevant Friday/Monday sequence. |
| Error handling | One outer `try/catch` abandons all later collection after a single access error. | Partial evidence is lost and the reason is not structured for later review. |
| Performance | CPU is cumulative process time, not utilization; no memory, disk, or sampled CPU measurement. | It cannot establish an endpoint performance symptom at collection time. |
| Profiles and desktop | Inspects only the executing account's desktop; no profile state, temporary-profile, public desktop, OneDrive, or folder-redirection evidence. | It can misdiagnose missing shortcuts when Service Desk runs under another account. |
| Network and identity | Captures only DNS servers. | It omits domain membership, adapters, addressing, routes, DC discovery, and authentication-relevant records. |
| Output and logging | Uses a shared `C:\Temp` path, no timestamp/run manifest/transcript, and a free-text error file. | Evidence can overwrite prior runs and lacks useful provenance. |
| Security and privacy | No warning that event messages, user paths, and DMS configuration may contain sensitive matter information. | Output could be mishandled outside the incident case. |

## 4. Hand-Corrected Production Version

The complete executable production version is [floor6-deployment-evidence-collection.ps1](floor6-deployment-evidence-collection.ps1). It includes comment-based help, input validation, a no-write `-DryRun`, timestamped output, transcript logging, per-area error capture, and structured JSON/CSV artifacts.

- Uses uninstall-registry inventory rather than `Win32_Product`.
- Searches software, service metadata, and installed-file timestamps using `-DmsName` and `-DeploymentStart`.
- Collects bounded event windows and caps events/files to limit endpoint impact.
- Continues after a failed collection area and records failures in `CollectionErrors.json`.
- Captures resource snapshots, profile/redirection state, desktop paths and shortcut inventory, Group Policy output, and domain/network configuration.
- Does not uninstall, install, alter registry values, stop services, terminate processes, start policy sync, reboot, or change environment settings.

Service Desk may not see the affected user's `HKCU` settings or Security log. The script records collector and interactive identities. Run in the affected user's session where practical, or use an approved user-context collection. The script neither accesses cloud content nor attempts to reproduce the matter exposure.

## 5. Side-by-Side Comparison

| AI Draft Section | Hand-Corrected Section | What Was Fixed | Why It Matters |
|---|---|---|---|
| Software inventory | `Get-InstalledApplications` | Replaced `Win32_Product` with 32-bit and 64-bit uninstall registry reads. | Avoids MSI repair activity and preserves a defensible read-only collection. |
| Event log handling | `EventLogs.csv`, `LoginEvents.csv` | Adds a bounded time window, Application/System/Security/Group Policy sources, event normalization, caps, and isolated errors. | Captures relevant sign-in/deployment signals without failing the run. |
| Error handling | `Invoke-ReadOnlyCollection`, `CollectionErrors.json` | Replaces one global failure point with per-area errors. | Makes missing evidence visible while preserving other artifacts. |
| Performance data | `Performance.json`, `Processes.csv` | Adds sampled total CPU, memory usage, fixed-disk capacity, process start times, memory, and cumulative CPU. | Separates a current performance symptom from historical process consumption. |
| User profile collection | `UserProfile.json`, `DesktopVerification.json` | Captures collector/interactive identity, profile state/refcount, temporary-profile indicators, User Shell Folder values, OneDrive metadata, public/current desktop paths. | Directly evaluates profile, desktop, and redirection explanations. |
| Deployment evidence | `DmsMatches.json`, `Services.csv`, `DeploymentFileTimestamps.csv` | Adds DMS-specific inventory and a defined deployment window. | Makes the causal comparison testable rather than assuming temporal proximity. |
| Policy evidence | `GroupPolicy.txt`, Group Policy events | Adds `gpresult` and policy-processing event evidence. | Supports or refutes policy and folder-redirection changes. |
| Network/domain evidence | `NetworkInfo.json` | Adds adapters, IP addressing, DNS, routes, domain membership, and DC discovery. | Identifies infrastructure symptoms that could mimic a deployment problem. |
| Output structure | timestamped folder, transcript, manifest in summary | Prevents overwrites and records what ran, when, and which artifacts were produced. | Improves chain-of-custody and repeatability. |

## 6. Expected Output Example

```text
Evidence-Floor6-WS123-20260810-091530/
|-- SystemInfo.json
|-- InstalledSoftware.csv
|-- DmsMatches.json
|-- StartupApplications.csv
|-- ScheduledTasks.csv
|-- Processes.csv
|-- Performance.json
|-- Services.csv
|-- EventLogs.csv
|-- LoginEvents.csv
|-- GroupPolicy.txt
|-- UserProfile.json
|-- DesktopVerification.json
|-- DesktopShortcuts.csv
|-- NetworkInfo.json
|-- DeploymentFileTimestamps.csv
|-- CollectionErrors.json
|-- SummaryReport.json
`-- Transcript.log
```

Copy the whole folder to the approved incident evidence location and retain the endpoint copy according to incident retention procedure. Do not email raw event logs or user-profile exports outside the approved case channel.

## 7. Evidence Interpretation Guide

| Artifact | What to look for | Supports deployment causation | Weighs against deployment causation | Escalate when |
|---|---|---|---|---|
| `SystemInfo.json` | OS build, boot time, interactive user, domain state. | Affected endpoints share deployment cohort, build, or reboot pattern. | Failures span unrelated cohorts or predate Friday. | Domain membership is absent/unexpected or boot/update timing is inconsistent. |
| `DmsMatches.json`, `InstalledSoftware.csv` | Product/version/publisher/install date/location. | Same new version or unexpected install state appears across affected devices. | DMS is absent/unchanged while symptoms occur, or unaffected endpoints match exactly. | Product identity/version differs from deployment records. |
| `DeploymentFileTimestamps.csv` | Executables/configuration written during defined window. | DMS components changed Friday and correlate with onset. | Relevant files predate deployment or timestamps are unrelated. | Unexpected binaries/config files require package/security review. |
| `Services.csv`, `StartupApplications.csv`, `ScheduledTasks.csv` | New DMS services/tasks/startup commands, failed state, unexpected command paths. | Component starts at sign-in or fails on affected devices. | No DMS-associated persistence exists and another component dominates. | Unsigned/unexpected paths, repeated failures, or privileged task identity. |
| `Performance.json`, `Processes.csv` | CPU, memory pressure, disk free space, long-running/new processes. | DMS process/service consumes resources after deployment. | Disk exhaustion, another process, or hardware symptoms explain performance. | Sustained high utilization, critical disk free space, or crashes. |
| `LoginEvents.csv`, `EventLogs.csv` | 4625/4740/4771/4776, profile, Netlogon, Group Policy, DMS errors. | Common DMS/config fault follows deployment or appears during affected logons. | Bad-password, lockout, DC, DNS, or profile errors predate deployment and have no DMS link. | Account lockouts, widespread auth failures, crashes, or policy failures. |
| `GroupPolicy.txt` | Applied GPOs, slow-link/process failures, folder-redirection policy. | Newly applied policy/package setting maps to rollout timing. | Required policies absent or infrastructure policy fails independently. | Conflicting policy, inaccessible SYSVOL, repeated policy errors. |
| `UserProfile.json` | Profile path/state/refcount, temp flag, Desktop/OneDrive paths. | Temporary profile or changed desktop redirect begins with deployment. | Normal state with desktop files present. | Temporary profile, profile-load fault, unavailable redirected path. |
| `DesktopVerification.json`, `DesktopShortcuts.csv` | Expected Desktop/Public Desktop presence and timestamps. | Shortcuts changed in deployment window or desktop path changed. | Shortcuts exist at expected location; issue is shell/display/user-specific. | Desktop points to unavailable share/OneDrive or shortcut targets are abnormal. |
| `NetworkInfo.json` | DNS servers, routes, adapter state, DC lookup. | Only when DMS requires a new network dependency that fails consistently. | DC/DNS/routing failure independently explains sign-in/resource issues. | No DC discovery, bad DNS, gateway/routing, broad adapter failure. |
| `CollectionErrors.json`, `Transcript.log` | Access denied, unavailable logs, command failures. | Not causal by themselves. | Not causal by themselves. | A critical artifact is missing; rerun with approved elevation/user context. |

## 8. Final Incident Responder Assessment

This collector is sufficient for first-response workstation triage. It establishes a preserved local baseline and lets responders compare affected and unaffected Floor 6 endpoints without altering either device. It does **not** prove enterprise-wide causation, determine cloud authorization, or replace package/deployment telemetry.

Required central evidence: Intune/Configuration Manager deployment status, detection-rule/install logs, package hashes and command lines, Entra ID sign-in/device logs, domain-controller Security/Netlogon records, Group Policy/SYSVOL availability, DNS/DHCP/VPN telemetry, endpoint security telemetry, OneDrive Known Folder Move status, DMS server logs, and Microsoft Purview Audit/Copilot/SharePoint/DMS permission records for the reported matter. Preserve the user’s exact prompt, response, timestamp, account, device, and matter identifier through the approved legal/privacy process; do not investigate content access from endpoint data alone.

Rollback of the Friday deployment is justified when multiple affected devices show the same newly installed DMS version/component, a reproducible sign-in/performance/profile/shortcut failure begins afterward, logs or telemetry attribute failure to that component, and an unaffected control or approved rollback test confirms the relationship. Obtain change and incident approval before rollback.

Shift toward infrastructure, identity, or networking when evidence shows DC discovery/DNS failures, widespread Kerberos/NTLM/account-lockout patterns, missing SYSVOL/policy processing, profile/OneDrive failures unrelated to the DMS, or symptoms on devices outside the deployment cohort. Treat the Copilot report as a potential authorization/data-governance incident until central audit evidence determines whether it arose through an authorized source, stale permission, sharing path, or indexing/access-control defect.