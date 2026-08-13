# KB (L2/L3): Finance Shared Drives Not Accessible - Intune SYSTEM Context Script Failure

Version: v1.0
Date: 10/08/2026
Status: Draft

## Scope
Use this KB when all or most Finance users lose mapped drives after migration from GPO logon mapping to Intune script mapping.

## RCA Summary
Drive mapping script `Map-FinBridgeDrives.ps1` was moved from USER-context GPO logon execution to SYSTEM-context Intune execution without script redesign. The script attempted UNC access (`\\finbridge-fs01\Finance`) at logon time from SYSTEM context, failed with `network name cannot be found`, and had no retry path.

## Evidence Pattern
- Intune log: `Script context: SYSTEM account`
- Intune log: UNC path inaccessible at execution time
- Intune log: `Exit code: 1` and `Network name cannot be found`
- Intune log: `No retry configured`
- System log: `Workstation service entered running state` after script had already failed
- GroupPolicy Event 1500 success (confirms this is not a GP processing failure)
- NTFS warning about drive letter assignment failure (downstream symptom)

## Technical Triage
1. Confirm issue scope in Finance device/user groups.
2. Inspect Intune assignment for `Map-FinBridgeDrives.ps1`.
3. Validate execution context is SYSTEM on failing assignment.
4. Validate failure sequence in `IntuneManagementExtension.log`.
5. Confirm user-context baseline worked previously (change note, pilot endpoint, or historical config).

## Resolution
1. Remove Finance target from failing SYSTEM-context assignment.
2. Create replacement assignment that runs in user context.
3. Trigger sync on test endpoint.
4. Sign out/in with Finance test user.
5. Validate mapped drive appears and opens.

## Verification
- No new failures for `Map-FinBridgeDrives.ps1` in IntuneManagementExtension log.
- Finance drive letter (S:) is present for test user.
- UNC opens successfully for test user.
- No fresh widespread drive-loss tickets from DESKTOP-FB* in observation window.

## Escalation Criteria
Escalate to endpoint engineering if any of the following apply:
- User-context assignment still fails on multiple devices.
- UNC path access fails even when user-context mapping is confirmed.
- Additional authentication/share ACL failures appear.

## Required Escalation Package
- Script assignment screenshots (before and after)
- `IntuneManagementExtension.log` snippet covering failure and post-fix windows
- One affected and one recovered endpoint detail
- Error screenshot from user
