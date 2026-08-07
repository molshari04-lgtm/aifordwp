# Temp Cleanup Safe Script (PowerShell 5.1)

Script: `temp-cleanup-safe.ps1`

This script is designed for managed Windows endpoints and uses a safe cleanup approach:
- Finds temp files older than a configurable age.
- Supports dry-run mode.
- Skips locked files without stopping.
- Logs all actions.
- Moves files to quarantine (instead of hard delete) to support rollback.

## Options

- `-OlderThanDays <int>`
  - Files with `LastWriteTime` older than this many days are targeted.
  - Default: `0`.

- `-DryRun`
  - No file changes.
  - Prints files that would be moved during cleanup.

- `-TargetPaths <string[]>`
  - Temp locations to scan.
  - Default:
    - `$env:TEMP`
    - `$env:WINDIR\Temp`

- `-WorkingRoot <string>`
  - Root folder for logs, quarantine files, and rollback manifests.
  - Default: `$env:ProgramData\DWP-TempCleanup`.

- `-Rollback`
  - Enables rollback mode.

- `-RollbackManifest <string>`
  - Path to a manifest produced by a previous cleanup run.
  - Required when `-Rollback` is used.

## Example Usage

Dry run (preview only):

```powershell
.\temp-cleanup-safe.ps1 -DryRun -OlderThanDays 7
```

Cleanup run:

```powershell
.\temp-cleanup-safe.ps1 -OlderThanDays 7
```

Cleanup a custom path list:

```powershell
.\temp-cleanup-safe.ps1 -OlderThanDays 14 -TargetPaths "C:\Windows\Temp", "C:\Users\Public\Downloads"
```

Rollback a specific run:

```powershell
.\temp-cleanup-safe.ps1 -Rollback -RollbackManifest "C:\ProgramData\DWP-TempCleanup\Manifests\manifest-20260806-184500.json"
```

## Logging and Rollback Artifacts

By default the script writes to:
- Logs: `C:\ProgramData\DWP-TempCleanup\Logs`
- Quarantine: `C:\ProgramData\DWP-TempCleanup\Quarantine\<runstamp>`
- Manifests: `C:\ProgramData\DWP-TempCleanup\Manifests`

Each cleanup run creates:
- A timestamped log file.
- A timestamped manifest file used for rollback.

## Idempotency Notes

- Re-running cleanup is safe because already-moved files are no longer present at source.
- Missing files are skipped and logged.
- Rollback skips files if destination already exists.

## Verify Before Running

- Run in elevated PowerShell when targeting protected temp paths.
- Confirm enough disk space in `WorkingRoot` for quarantined files.
- Confirm retention and security policy allows quarantine storage in ProgramData.
