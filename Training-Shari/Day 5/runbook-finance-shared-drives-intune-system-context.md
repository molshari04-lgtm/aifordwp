Title: Finance Team Cannot Access Shared Drives (Intune Script Context Fault)
Version: 1.0
Date: 10/08/2026
Author: Sathishbabu
Reviewed: self
Status: draft
Change: initial version from FAULT-B RCA

# Runbook: Finance Shared Drives Fail Due to SYSTEM-Context Mapping Script

## 1) Prerequisites
Access and permissions:
- [ ] Intune admin access to `Devices > Scripts and remediations > Platform scripts`. [Elevated permissions required]
- [ ] Permission to edit assignment for `Map-FinBridgeDrives.ps1`. [Elevated permissions required]
- [ ] Access to one affected endpoint as local admin. [Elevated permissions required]
- [ ] Permission to run `Company Portal` sync or Intune sync on test endpoint. [Elevated permissions required]

Tools and systems:
- [ ] Intune admin center is reachable.
- [ ] Event Viewer is available on affected endpoint.
- [ ] Command Prompt is available on affected endpoint.
- [ ] Access to `IntuneManagementExtension.log` on endpoint:
  `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`

Mandatory user/ticket information:
- [ ] Affected username and device name.
- [ ] Drive letter that failed (for example `S:`).
- [ ] First failure time.
- [ ] Error screenshot/text from user.
- [ ] Confirmation that issue affects multiple Finance users.

## 2) Procedure
1. Open Intune admin center and navigate to `Devices > Scripts and remediations > Platform scripts`.
Expected result: Platform scripts list is visible.

2. Select `Map-FinBridgeDrives.ps1`.
Expected result: Script overview and assignment tabs are visible.

3. Open script settings and verify execution context is `System`.
Expected result: Current run context shows SYSTEM.

4. Remove Finance assignment from the failing SYSTEM-context script. [Elevated permissions required]
Expected result: Finance user/device group is no longer targeted by this script.

5. Save the assignment change. [Elevated permissions required]
Expected result: Assignment update is accepted without error.

6. Create a replacement user-context mapping script assignment for Finance users. [Elevated permissions required]
Expected result: New assignment targets Finance users and runs in user context.

7. Open affected endpoint and navigate to:
`Event Viewer > Applications and Services Logs > Microsoft > Windows > DeviceManagement-Enterprise-Diagnostics-Provider > Admin`.
Expected result: MDM policy processing log is visible.

8. Trigger device sync from endpoint (`Settings > Accounts > Access work or school > <work account> > Info > Sync`).
Expected result: Sync completes without error.

9. Open endpoint log file:
`C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`.
Expected result: Log opens in text viewer.

10. Search for `Map-FinBridgeDrives.ps1` in the log.
Expected result: Latest entries show user-context execution or no SYSTEM-targeted run for Finance assignment.

11. Sign out the test Finance user session.
Expected result: User is signed out successfully.

12. Sign in with a Finance test user.
Expected result: User desktop session loads normally.

13. Open `File Explorer > This PC`.
Expected result: `S:` (and other required Finance drives) appears.

14. Open `S:` drive.
Expected result: `\\finbridge-fs01\Finance` contents open without error.

## 3) Verification
1. In Intune admin center, confirm old SYSTEM-context assignment no longer targets Finance.
Location: `Devices > Scripts and remediations > Platform scripts > Map-FinBridgeDrives.ps1 > Assignments`.
Expected result: Finance target removed from failing assignment.

2. In Intune admin center, confirm replacement assignment targets Finance users in user context.
Location: replacement script assignment details.
Expected result: Assignment mode is user-context for Finance group.

3. On affected endpoint, verify no fresh failures for this script.
Location: `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`.
Expected result: No new `Exit code: 1` / `Network name cannot be found` for current session.

4. On affected endpoint, verify mapped drive exists.
Location: `File Explorer > This PC`.
Expected result: `S:` drive is present.

5. On affected endpoint, verify mapped drive opens.
Location: open `S:`.
Expected result: User can browse Finance share.

6. In incident queue, verify no new Finance-wide drive failures for 30 minutes.
Expected result: No recurring spike from DESKTOP-FB* devices.

## 4) Rollback
Use rollback if the replacement assignment causes wider impact or users lose access after change.

1. Re-open Intune script assignment for `Map-FinBridgeDrives.ps1`.
Location: `Devices > Scripts and remediations > Platform scripts > Map-FinBridgeDrives.ps1`.
Expected result: Assignment editor opens.

2. Revert to last known working assignment state from change record. [Elevated permissions required]
Expected result: Previous assignment configuration is restored.

3. Disable the newly created replacement assignment. [Elevated permissions required]
Expected result: New assignment is no longer active.

4. Save assignment changes. [Elevated permissions required]
Expected result: Intune accepts rollback configuration.

5. Trigger sync on one affected test endpoint.
Location: `Settings > Accounts > Access work or school > <work account> > Info > Sync`.
Expected result: Endpoint receives rollback policy.

6. Sign out and sign in on test endpoint.
Expected result: Session reloads with rollback state.

7. Validate drive access on test endpoint.
Location: `File Explorer > This PC > S:`.
Expected result: Drive behavior matches pre-change baseline.

8. If still broken, temporarily publish user communication to stop retries and escalate to endpoint engineering with log bundle.
Log bundle locations:
- `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`
- `Event Viewer > Windows Logs > System` (events around failure timestamp)
Expected result: Incident is contained and escalated with actionable data.

## 5) Notes
- This is not a Group Policy failure pattern when Event 1500 shows success.
- Core fault is execution context mismatch (SYSTEM vs USER) for UNC drive mapping.
- Timing risk: if script runs before session/network dependencies are ready and no retry exists, mapping fails for that sign-in.
- Edge case: if user-context script is correct but drive still missing, verify share ACLs and name resolution separately.
- Related signals from FAULT-B:
  - `Script context: SYSTEM account`
  - `Network path ... not accessible`
  - `Exit code: 1. Error: Network name cannot be found`
  - `No retry configured`
