<#
.SYNOPSIS
Collects read-only endpoint evidence for the Floor 6 Friday DMS deployment incident.
.DESCRIPTION
Writes an incident evidence package only; it does not change configuration, services, processes,
registry values, installed software, policies, or user data. DryRun writes nothing.
.PARAMETER DmsName
Name fragment used to identify the deployed DMS in software, services, and files.
.EXAMPLE
.\floor6-deployment-evidence-collection.ps1 -DmsName 'Contoso DMS' -DeploymentStart '2026-08-07 13:00'
.EXAMPLE
.\floor6-deployment-evidence-collection.ps1 -DmsName 'Contoso DMS' -DryRun
.NOTES
Run elevated for the fullest Security and Group Policy evidence. Protect output as incident data.
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

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:Errors = [System.Collections.Generic.List[object]]::new()
$script:Artifacts = [System.Collections.Generic.List[object]]::new()
$script:Started = Get-Date
$script:OutputPath = $null

function Add-CollectionError {
    param([string]$Area, [System.Management.Automation.ErrorRecord]$ErrorRecord)
    $script:Errors.Add([pscustomobject]@{ Timestamp = Get-Date; Area = $Area; Message = $ErrorRecord.Exception.Message })
    Write-Warning "[$Area] $($ErrorRecord.Exception.Message)"
}
function Invoke-ReadOnlyCollection {
    param([string]$Area, [scriptblock]$ScriptBlock)
    try { & $ScriptBlock } catch { Add-CollectionError $Area $_; $null }
}
function Write-EvidenceJson {
    param([string]$Name, [AllowNull()][object]$InputObject, [int]$Depth = 8)
    $path = Join-Path $script:OutputPath "$Name.json"
    @($InputObject) | ConvertTo-Json -Depth $Depth | Set-Content -LiteralPath $path -Encoding UTF8
    $script:Artifacts.Add([pscustomobject]@{ Artifact = "$Name.json"; Type = 'JSON'; Path = $path })
}
function Write-EvidenceCsv {
    param([string]$Name, [AllowNull()][object]$InputObject = @())
    $path = Join-Path $script:OutputPath "$Name.csv"
    $records = @($InputObject | Where-Object { $null -ne $_ })
    if ($records.Count -gt 0) {
        $records | Export-Csv -LiteralPath $path -NoTypeInformation -Encoding UTF8
    }
    else {
        Set-Content -LiteralPath $path -Value '' -Encoding UTF8
    }
    $script:Artifacts.Add([pscustomobject]@{ Artifact = "$Name.csv"; Type = 'CSV'; Path = $path })
}
function Get-OptionalPropertyValue {
    param([object]$Object, [string]$Name)
    $property = $Object.PSObject.Properties[$Name]
    if ($null -ne $property) { return $property.Value }
    return $null
}
function ConvertTo-EventEvidence {
    param([System.Diagnostics.Eventing.Reader.EventRecord]$Event)
    try { $message = (($Event.Message -replace '[\r\n]+', ' ') -replace '\s+', ' ').Trim() } catch { $message = '<Message unavailable>' }
    [pscustomobject]@{ LogName = $Event.LogName; TimeCreated = $Event.TimeCreated; Id = $Event.Id; Level = $Event.LevelDisplayName; ProviderName = $Event.ProviderName; RecordId = $Event.RecordId; Message = $message }
}
function Get-InstalledApplications {
    $paths = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    foreach ($path in $paths) {
        Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | Where-Object {
            $displayNameProperty = $_.PSObject.Properties['DisplayName']
            $null -ne $displayNameProperty -and -not [string]::IsNullOrWhiteSpace([string]$displayNameProperty.Value)
        } | ForEach-Object {
            [pscustomobject]@{ DisplayName = Get-OptionalPropertyValue $_ 'DisplayName'; DisplayVersion = Get-OptionalPropertyValue $_ 'DisplayVersion'; Publisher = Get-OptionalPropertyValue $_ 'Publisher'; InstallDate = Get-OptionalPropertyValue $_ 'InstallDate'; InstallLocation = Get-OptionalPropertyValue $_ 'InstallLocation'; UninstallString = Get-OptionalPropertyValue $_ 'UninstallString'; RegistryPath = $_.PSPath }
        }
    }
}
function Get-ShortcutEvidence {
    param([string[]]$DesktopPaths)
    foreach ($desktopPath in ($DesktopPaths | Where-Object { $_ } | Select-Object -Unique)) {
        if (-not (Test-Path -LiteralPath $desktopPath)) {
            [pscustomobject]@{ DesktopPath = $desktopPath; Exists = $false; ShortcutPath = $null; LastWriteTime = $null; Length = $null }
            continue
        }
        Get-ChildItem -LiteralPath $desktopPath -Filter '*.lnk' -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
            [pscustomobject]@{ DesktopPath = $desktopPath; Exists = $true; ShortcutPath = $_.FullName; LastWriteTime = $_.LastWriteTime; Length = $_.Length }
        }
    }
}

$ended = Get-Date
$eventStart = $ended.AddDays(-$DaysBack)
$deploymentEnd = $DeploymentStart.AddDays(3)
$runStamp = $script:Started.ToString('yyyyMMdd-HHmmss')
if ($DryRun) {
    [pscustomobject]@{
        Mode = 'DryRun - no files will be written'; ComputerName = $env:COMPUTERNAME; DmsName = $DmsName
        IsAdministrator = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        EventWindowStart = $eventStart; DeploymentStart = $DeploymentStart
        OutputPathThatWouldBe = Join-Path $OutputRoot "Evidence-Floor6-$env:COMPUTERNAME-$runStamp"
        PlannedArtifacts = 'SystemInfo.json, InstalledSoftware.csv, DmsMatches.json, StartupApplications.csv, ScheduledTasks.csv, Processes.csv, Performance.json, Services.csv, EventLogs.csv, LoginEvents.csv, GroupPolicy.txt, UserProfile.json, DesktopVerification.json, DesktopShortcuts.csv, NetworkInfo.json, DeploymentFileTimestamps.csv, CollectionErrors.json, SummaryReport.json, Transcript.log'
    } | Format-List
    return
}

$script:OutputPath = Join-Path $OutputRoot "Evidence-Floor6-$env:COMPUTERNAME-$runStamp"
New-Item -ItemType Directory -Path $script:OutputPath -Force | Out-Null
$transcriptPath = Join-Path $script:OutputPath 'Transcript.log'
Start-Transcript -LiteralPath $transcriptPath -Force | Out-Null
try {
    Write-Host "Collecting read-only evidence to $script:OutputPath" -ForegroundColor Cyan
    $systemInfo = Invoke-ReadOnlyCollection 'System identity' {
        $os = Get-CimInstance Win32_OperatingSystem; $computer = Get-CimInstance Win32_ComputerSystem; $bios = Get-CimInstance Win32_BIOS
        [pscustomobject]@{ CollectionTime = Get-Date; ComputerName = $env:COMPUTERNAME; LoggedOnUser = $computer.UserName; Domain = $computer.Domain; PartOfDomain = $computer.PartOfDomain; Manufacturer = $computer.Manufacturer; Model = $computer.Model; SerialNumber = $bios.SerialNumber; OSName = $os.Caption; OSVersion = $os.Version; BuildNumber = $os.BuildNumber; LastBootTime = $os.LastBootUpTime; UptimeHours = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 2); IsAdministrator = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) }
    }
    Write-EvidenceJson 'SystemInfo' $systemInfo

    $software = @(Invoke-ReadOnlyCollection 'Installed software' { Get-InstalledApplications })
    Write-EvidenceCsv 'InstalledSoftware' $software
    $escapedDmsName = [regex]::Escape($DmsName)
    $dmsMatches = @($software | Where-Object { $null -ne $_ -and "$($_.DisplayName) $($_.Publisher) $($_.InstallLocation)" -match $escapedDmsName })
    Write-EvidenceJson 'DmsMatches' $dmsMatches

    $startup = @(Invoke-ReadOnlyCollection 'Startup applications' {
        $runKeys = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
        foreach ($key in $runKeys) { if (Test-Path -LiteralPath $key) { (Get-ItemProperty -LiteralPath $key).PSObject.Properties | Where-Object Name -NotMatch '^PS' | ForEach-Object { [pscustomobject]@{ Source = $key; Name = $_.Name; Command = [string]$_.Value } } } }
        Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue | ForEach-Object { [pscustomobject]@{ Source = $_.Location; Name = $_.Name; Command = $_.Command } }
    })
    Write-EvidenceCsv 'StartupApplications' $startup

    $tasks = @(Invoke-ReadOnlyCollection 'Scheduled tasks' { Get-ScheduledTask | ForEach-Object { [pscustomobject]@{ TaskName = $_.TaskName; TaskPath = $_.TaskPath; State = $_.State; Author = $_.Author; Description = $_.Description; UserId = $_.Principal.UserId } } })
    Write-EvidenceCsv 'ScheduledTasks' $tasks

    $processes = @(Invoke-ReadOnlyCollection 'Running processes' { Get-Process | ForEach-Object { [pscustomobject]@{ ProcessName = $_.ProcessName; Id = $_.Id; Path = $_.Path; StartTime = $_.StartTime; WorkingSetMB = [math]::Round($_.WorkingSet64 / 1MB, 2); CPUSeconds = $_.CPU } } })
    Write-EvidenceCsv 'Processes' $processes

    $performance = Invoke-ReadOnlyCollection 'Performance snapshot' {
        $os = Get-CimInstance Win32_OperatingSystem; $computer = Get-CimInstance Win32_ComputerSystem
        try { $cpu = [math]::Round((Get-Counter '\Processor Information(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1).CounterSamples[0].CookedValue, 2) } catch { $cpu = $null }
        [pscustomobject]@{ CollectionTime = Get-Date; CPUPercent = $cpu; TotalMemoryGB = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2); FreeMemoryGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2); UsedMemoryPercent = [math]::Round((1 - (($os.FreePhysicalMemory * 1KB) / $computer.TotalPhysicalMemory)) * 100, 2); Disks = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType = 3' | ForEach-Object { [pscustomobject]@{ Drive = $_.DeviceID; SizeGB = [math]::Round($_.Size / 1GB, 2); FreeGB = [math]::Round($_.FreeSpace / 1GB, 2); FreePercent = if ($_.Size) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 2) } else { $null } } }) }
    }
    Write-EvidenceJson 'Performance' $performance

    $services = @(Invoke-ReadOnlyCollection 'DMS services' { Get-CimInstance Win32_Service | Where-Object { "$($_.Name) $($_.DisplayName) $($_.PathName)" -match $escapedDmsName } | Select-Object Name, DisplayName, State, StartMode, StartName, PathName, ProcessId })
    Write-EvidenceCsv 'Services' $services

    $allEvents = [System.Collections.Generic.List[object]]::new(); $loginEvents = [System.Collections.Generic.List[object]]::new()
    foreach ($logName in 'Application', 'System', 'Security', 'Microsoft-Windows-GroupPolicy/Operational') {
        $events = Invoke-ReadOnlyCollection "Event log $logName" { Get-WinEvent -FilterHashtable @{ LogName = $logName; StartTime = $eventStart } -MaxEvents $MaxEventsPerLog }
        foreach ($event in @($events)) {
            if ($null -eq $event) { continue }
            $record = ConvertTo-EventEvidence $event; $allEvents.Add($record)
            if (($record.LogName -eq 'Security' -and $record.Id -in 4624,4625,4648,4672,4740,4771,4776) -or ($record.LogName -eq 'System' -and $record.ProviderName -match 'Netlogon|User Profile Service|GroupPolicy')) { $loginEvents.Add($record) }
        }
    }
    Write-EvidenceCsv 'EventLogs' $allEvents.ToArray(); Write-EvidenceCsv 'LoginEvents' $loginEvents.ToArray()

    $gpPath = Join-Path $script:OutputPath 'GroupPolicy.txt'
    Invoke-ReadOnlyCollection 'Group Policy results' { & gpresult.exe /r 2>&1 | Out-File -LiteralPath $gpPath -Encoding UTF8; $script:Artifacts.Add([pscustomobject]@{ Artifact = 'GroupPolicy.txt'; Type = 'Text'; Path = $gpPath }) } | Out-Null

    $profile = Invoke-ReadOnlyCollection 'User profile and redirection' {
        $computer = Get-CimInstance Win32_ComputerSystem; $sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value; $key = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid"
        $profileKey = if (Test-Path -LiteralPath $key) { Get-ItemProperty -LiteralPath $key } else { $null }; $folders = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ErrorAction SilentlyContinue
        $oneDrive = Get-ChildItem 'HKCU:\Software\Microsoft\OneDrive\Accounts' -ErrorAction SilentlyContinue | ForEach-Object { Get-ItemProperty $_.PSPath }
        [pscustomobject]@{ CollectorIdentity = [Security.Principal.WindowsIdentity]::GetCurrent().Name; InteractiveUser = $computer.UserName; CurrentUserSid = $sid; ProfileImagePath = $profileKey.ProfileImagePath; ProfileState = $profileKey.State; ProfileRefCount = $profileKey.RefCount; TemporaryProfileIndicator = [bool](($profileKey.ProfileImagePath -match '(?i)\\temp($|\\)') -or (($profileKey.State -band 0x8000) -ne 0)); DesktopUserShellFolder = $folders.Desktop; DocumentsUserShellFolder = $folders.Personal; DesktopLooksRedirected = [bool]($folders.Desktop -match '^\\\\|OneDrive'); OneDriveAccounts = @($oneDrive | Select-Object UserFolder, TenantName, BusinessName) }
    }
    Write-EvidenceJson 'UserProfile' $profile

    $desktopPaths = @([Environment]::GetFolderPath('Desktop'), (Join-Path $env:PUBLIC 'Desktop'))
    $desktopVerification = @($desktopPaths | ForEach-Object { [pscustomobject]@{ Path = $_; Exists = Test-Path -LiteralPath $_; ItemCount = if (Test-Path -LiteralPath $_) { @(Get-ChildItem -LiteralPath $_ -Force -ErrorAction SilentlyContinue).Count } else { 0 } } })
    Write-EvidenceJson 'DesktopVerification' $desktopVerification
    $shortcuts = @(Invoke-ReadOnlyCollection 'Desktop shortcut inventory' { Get-ShortcutEvidence $desktopPaths })
    Write-EvidenceCsv 'DesktopShortcuts' $shortcuts

    $network = Invoke-ReadOnlyCollection 'Network and domain connectivity' {
        $computer = Get-CimInstance Win32_ComputerSystem; $dcLookup = if ($computer.PartOfDomain) { & nltest.exe "/dsgetdc:$($computer.Domain)" 2>&1 } else { $null }
        [pscustomobject]@{ Domain = $computer.Domain; PartOfDomain = $computer.PartOfDomain; DomainControllerLookup = $dcLookup; Adapters = @(Get-NetAdapter -IncludeHidden -ErrorAction SilentlyContinue | Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress); IPConfiguration = @(Get-NetIPConfiguration -Detailed -ErrorAction SilentlyContinue | Select-Object InterfaceAlias, IPv4Address, IPv6Address, IPv4DefaultGateway, DNSServer, NetProfile); DnsClientServers = @(Get-DnsClientServerAddress -ErrorAction SilentlyContinue | Select-Object InterfaceAlias, AddressFamily, ServerAddresses); DefaultRoutes = @(Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Select-Object InterfaceAlias, NextHop, RouteMetric, State) }
    }
    Write-EvidenceJson 'NetworkInfo' $network

    $timestamps = [System.Collections.Generic.List[object]]::new()
    foreach ($app in $dmsMatches | Where-Object { $_.InstallLocation -and (Test-Path -LiteralPath $_.InstallLocation) }) {
        Invoke-ReadOnlyCollection "Deployment file timestamps: $($app.DisplayName)" { Get-ChildItem -LiteralPath $app.InstallLocation -File -Force -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -ge $DeploymentStart -and $_.LastWriteTime -le $deploymentEnd } | Select-Object -First $MaxFileTimestampResults | ForEach-Object { $timestamps.Add([pscustomobject]@{ Application = $app.DisplayName; Path = $_.FullName; CreationTime = $_.CreationTime; LastWriteTime = $_.LastWriteTime; Length = $_.Length }) } } | Out-Null
    }
    Write-EvidenceCsv 'DeploymentFileTimestamps' $timestamps.ToArray()

    Write-EvidenceJson 'CollectionErrors' $script:Errors.ToArray()
    $summary = [pscustomobject]@{ Investigation = 'Floor 6 Friday deployment-related endpoint impact'; CollectionStarted = $script:Started; CollectionCompleted = Get-Date; ComputerName = $env:COMPUTERNAME; DmsName = $DmsName; DeploymentStart = $DeploymentStart; EventWindowStart = $eventStart; OutputPath = $script:OutputPath; DmsApplicationMatchCount = $dmsMatches.Count; DmsServiceMatchCount = $services.Count; EventCount = $allEvents.Count; LoginEventCount = $loginEvents.Count; ErrorCount = $script:Errors.Count; Artifacts = $script:Artifacts.ToArray() }
    Write-EvidenceJson 'SummaryReport' $summary
    Write-Host "Evidence collection complete: $script:OutputPath" -ForegroundColor Green
}
finally { try { Stop-Transcript | Out-Null } catch { } }