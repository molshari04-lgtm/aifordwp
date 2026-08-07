[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

# TO VERIFY BEFORE RUNNING:
# 1) Run in an elevated PowerShell session for complete access to event logs and session data.
# 2) Confirm outbound access to https://speed.cloudflare.com/__down?bytes=5000000 for the internet speed check.
# 3) The speed check downloads about 5 MB of test data and may be blocked by proxy/firewall policy.
# 4) The script counts logged-in users using quser when available; if quser is unavailable, a fallback method is used.

function Write-Section {
	param(
		[string]$Title
	)

	Write-Host ""
	Write-Host "===== $Title =====" -ForegroundColor Cyan
}

function Test-RebootIndicator {
	param(
		[Parameter(Mandatory = $true)]
		[string]$Path,

		[string]$ValueName
	)

	if (-not (Test-Path -LiteralPath $Path)) {
		return $false
	}

	if ([string]::IsNullOrWhiteSpace($ValueName)) {
		return $true
	}

	try {
		$item = Get-ItemProperty -LiteralPath $Path -Name $ValueName -ErrorAction Stop
		return $null -ne $item.$ValueName
	}
	catch {
		return $false
	}
}

Write-Host "Endpoint Health Report (Read-Only)" -ForegroundColor Green
Write-Host "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Computer: $env:COMPUTERNAME"

# 1) System uptime
# Reads OS last boot time and calculates total uptime without changing system state.
Write-Section -Title "1) System Uptime"
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$lastBoot = [datetime]$os.LastBootUpTime
$uptime = (Get-Date) - $lastBoot
[pscustomobject]@{
	LastBootTime = $lastBoot
	UptimeDays   = [math]::Floor($uptime.TotalDays)
	UptimeHours  = $uptime.Hours
	UptimeMins   = $uptime.Minutes
} | Format-List

# 2) Free disk space
# Lists free and total space for local fixed disks only.
Write-Section -Title "2) Free Disk Space"
Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" |
	Select-Object DeviceID,
	@{Name = "SizeGB"; Expression = { [math]::Round($_.Size / 1GB, 2) } },
	@{Name = "FreeGB"; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) } },
	@{Name = "FreePercent"; Expression = {
		if ($_.Size -gt 0) {
			[math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
		}
		else {
			$null
		}
	} } |
	Format-Table -AutoSize

# 3) Pending reboot status
# Checks common reboot-required registry indicators in read-only mode.
Write-Section -Title "3) Pending Reboot (Registry Check)"
$rebootFlags = @()

if (Test-RebootIndicator -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") {
	$rebootFlags += "CBS RebootPending"
}

if (Test-RebootIndicator -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") {
	$rebootFlags += "WindowsUpdate RebootRequired"
}

if (Test-RebootIndicator -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -ValueName "PendingFileRenameOperations") {
	$rebootFlags += "PendingFileRenameOperations"
}

[pscustomobject]@{
	PendingReboot = ($rebootFlags.Count -gt 0)
	Indicators    = if ($rebootFlags.Count -gt 0) { $rebootFlags -join "; " } else { "None found" }
} | Format-List

# 4) Top 5 processes by memory
# Displays current top memory consumers by Working Set (RAM currently in use).
Write-Section -Title "4) Top 5 Processes by Memory (Working Set)"
Get-Process |
	Sort-Object -Property WorkingSet64 -Descending |
	Select-Object -First 5 ProcessName, Id,
	@{Name = "WorkingSetMB"; Expression = { [math]::Round($_.WorkingSet64 / 1MB, 2) } } |
	Format-Table -AutoSize

# 5) Top 5 processes by CPU
# Uses cumulative CPU seconds since process start (not instantaneous CPU percent).
Write-Section -Title "5) Top 5 Processes by CPU"
Get-Process |
	Where-Object { $null -ne $_.CPU } |
	Sort-Object -Property CPU -Descending |
	Select-Object -First 5 ProcessName, Id,
	@{Name = "CPUSeconds"; Expression = { [math]::Round($_.CPU, 2) } } |
	Format-Table -AutoSize

# 6) Last 5 system log errors
# Reads the latest five Error-level events from the System event log.
Write-Section -Title "6) Last 5 System Log Errors"
Get-WinEvent -FilterHashtable @{ LogName = "System"; Level = 2 } -MaxEvents 5 |
	Select-Object TimeCreated, Id, ProviderName,
	@{Name = "Message"; Expression = { (($_.Message -split "`r?`n")[0]).Trim() } } |
	Format-Table -Wrap -AutoSize

# 7) Internet speed
# Performs a read-only approximate download speed test by timing a small in-memory download.
Write-Section -Title "7) Internet Speed"
$speedUrl = "https://speed.cloudflare.com/__down?bytes=5000000"

try {
	$webClient = New-Object System.Net.WebClient
	$webClient.Proxy = [System.Net.WebRequest]::DefaultWebProxy
	if ($null -ne $webClient.Proxy) {
		$webClient.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
	}

	$timer = [System.Diagnostics.Stopwatch]::StartNew()
	$bytes = $webClient.DownloadData($speedUrl)
	$timer.Stop()

	$downloadedMB = [math]::Round($bytes.Length / 1MB, 2)
	$speedMbps = if ($timer.Elapsed.TotalSeconds -gt 0) {
		[math]::Round((($bytes.Length / 1MB) * 8) / $timer.Elapsed.TotalSeconds, 2)
	}
	else {
		$null
	}

	[pscustomobject]@{
		Status             = "Success"
		TestURL            = $speedUrl
		DownloadedMB       = $downloadedMB
		DurationSeconds    = [math]::Round($timer.Elapsed.TotalSeconds, 2)
		ApproxDownloadMbps = $speedMbps
	} | Format-List
}
catch {
	[pscustomobject]@{
		Status  = "Failed"
		TestURL = $speedUrl
		Error   = $_.Exception.Message
	} | Format-List
}
finally {
	if ($null -ne $webClient) {
		$webClient.Dispose()
	}
}

# 8) Microsoft Defender service status
# Checks whether the Defender service (WinDefend) is present and running.
Write-Section -Title "8) Microsoft Defender Service Status"
$defenderService = Get-Service -Name "WinDefend" -ErrorAction SilentlyContinue
if ($null -eq $defenderService) {
	[pscustomobject]@{
		ServiceName = "WinDefend"
		Present     = $false
		Running     = "to confirm"
		State       = "Service not found"
	} | Format-List
}
else {
	[pscustomobject]@{
		ServiceName = $defenderService.Name
		Present     = $true
		Running     = ($defenderService.Status -eq "Running")
		State       = $defenderService.Status
	} | Format-List
}

# 9) Logged-in user count
# Counts active user sessions using quser when available, with a fallback to current console user.
Write-Section -Title "9) Logged-In Users Count"
$sessionCount = $null
$sessionSource = ""

try {
	$quserOutput = quser 2>$null
	if ($LASTEXITCODE -eq 0 -and $quserOutput) {
		$sessionLines = $quserOutput | Select-Object -Skip 1 | Where-Object { $_.Trim() -ne "" }
		$sessionCount = ($sessionLines | Measure-Object).Count
		$sessionSource = "quser"
	}
}
catch {
	$sessionCount = $null
}

if ($null -eq $sessionCount) {
	$currentUser = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
	$sessionCount = if ([string]::IsNullOrWhiteSpace($currentUser)) { 0 } else { 1 }
	$sessionSource = "Win32_ComputerSystem fallback"
}

[pscustomobject]@{
	LoggedInUsers = $sessionCount
	Source        = $sessionSource
} | Format-List

# 10) Last Windows Update time
# Reports the most recent installed update date using Get-HotFix; falls back to update client event logs.
Write-Section -Title "10) Last Windows Update"

$latestHotFix = $null
try {
	$latestHotFix = Get-HotFix |
		Where-Object { $null -ne $_.InstalledOn -and $_.InstalledOn -ne "" } |
		Sort-Object -Property InstalledOn -Descending |
		Select-Object -First 1
}
catch {
	$latestHotFix = $null
}

if ($null -ne $latestHotFix) {
	[pscustomobject]@{
		Source          = "Get-HotFix"
		InstalledOn     = $latestHotFix.InstalledOn
		HotFixID        = $latestHotFix.HotFixID
		Description     = $latestHotFix.Description
	} | Format-List
}
else {
	try {
		$lastWuEvent = Get-WinEvent -FilterHashtable @{
			LogName      = "System"
			ProviderName = "Microsoft-Windows-WindowsUpdateClient"
			Id           = 19
		} -MaxEvents 1

		if ($null -ne $lastWuEvent) {
			[pscustomobject]@{
				Source       = "WindowsUpdateClient Event ID 19"
				LastUpdateAt = $lastWuEvent.TimeCreated
				EventId      = $lastWuEvent.Id
				Message      = (($lastWuEvent.Message -split "`r?`n")[0]).Trim()
			} | Format-List
		}
		else {
			[pscustomobject]@{
				Source       = "WindowsUpdateClient Event ID 19"
				LastUpdateAt = "to confirm"
				Note         = "No matching update events found"
			} | Format-List
		}
	}
	catch {
		[pscustomobject]@{
			Source       = "Windows Update fallback"
			LastUpdateAt = "to confirm"
			Note         = $_.Exception.Message
		} | Format-List
	}
}
