# Title: AVD Session Disconnects After Logon (DWM/igdumd64.dll)
# Version: 1.0
# Date: 07/08/2026
# Author: Sathishbabu
# Reviewed: self
# Status: draft
# Change: initial version from RCA

# Runbook: AVD Session Disconnects After Logon (DWM/igdumd64.dll)

## 1) Prerequisites
- [ ] Azure Portal access is confirmed for subscription and resource group hosting POOL-FIN-01. [Elevated permissions required]
- [ ] Azure role allows changing session host admission state (drain mode) in POOL-FIN-01. [Elevated permissions required]
- [ ] Local administrator access is confirmed on SHFIN-01-A and SHFIN-02-A. [Elevated permissions required]
- [ ] Event Viewer access is confirmed on SHFIN-01-A and SHFIN-02-A. [Elevated permissions required]
- [ ] Approved known-good Intel graphics driver package is available from the internal software repository. [Elevated permissions required]
- [ ] A test account for AVD sign-in validation is available.
- [ ] Mandatory end-user info is captured: affected username(s), first failure timestamp, host name shown in AVD client, screenshot/text of error, and whether reconnect loops occur.
- [ ] Mandatory incident scope is captured: affected host pool, whether issue is single user or multiple users, and whether unaffected users can still sign in.
- [ ] Change ticket ID is opened and linked to this runbook execution.

## 2) Procedure
1. Open Azure Portal and go to Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts.
   Expected result: Session host list shows SHFIN-01-A and current Session count.

2. Select SHFIN-01-A and set Allow new sessions to No (drain mode).
   Expected result: SHFIN-01-A shows drain mode enabled and no new sessions are assigned. [Elevated permissions required]

3. Wait until Session count for SHFIN-01-A reaches 0 in the Session hosts grid.
   Expected result: No active production sessions remain on SHFIN-01-A.

4. Open Remote Desktop Connection from the admin workstation and connect to SHFIN-01-A with local admin credentials.
   Expected result: Admin desktop session opens on SHFIN-01-A. [Elevated permissions required]

5. Open Event Viewer on SHFIN-01-A and navigate to Windows Logs > Application.
   Expected result: Application log entries are visible.

6. In Windows Logs > Application, run Filter Current Log with Event IDs 1000, set Logged time to incident window, and check Source Application Error.
   Expected result: Entries show Faulting application name dwm.exe and Faulting module name igdumd64.dll.

7. In Windows Logs > Application, run Filter Current Log with Event ID 9009 and Source Desktop Window Manager.
   Expected result: Desktop Window Manager exit events are present and timestamp-aligned with disconnects.

8. In Event Viewer, navigate to Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational and filter Event IDs 21 and 40.
   Expected result: Event 21 logons followed by near-immediate Event 40 disconnects are visible.

9. Connect to SHFIN-02-A and open Device Manager > Display adapters > Intel graphics adapter > Properties > Driver.
   Expected result: Known-good driver version and date are recorded from SHFIN-02-A baseline. [Elevated permissions required]

10. On SHFIN-01-A, open Device Manager > Display adapters > Intel graphics adapter > Properties > Driver and record current version and date.
    Expected result: Current SHFIN-01-A driver version is documented for change tracking. [Elevated permissions required]

11. On SHFIN-01-A, in Device Manager > Display adapters, right-click Intel graphics adapter and select Uninstall device, then select Delete the driver software for this device.
    Expected result: Existing Intel graphics driver package is removed. [Elevated permissions required]

12. Install the approved known-good Intel graphics driver package on SHFIN-01-A from the internal repository.
    Expected result: Driver installation completes without error. [Elevated permissions required]

13. Restart SHFIN-01-A from Start > Power > Restart.
    Expected result: Host reboots and returns reachable on RDP.

14. On SHFIN-01-A, open Device Manager > Display adapters > Intel graphics adapter > Properties > Driver and verify version/date match SHFIN-02-A baseline.
    Expected result: SHFIN-01-A driver version now matches known-good baseline. [Elevated permissions required]

15. In Azure Portal, return to Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts, select SHFIN-01-A, and set Allow new sessions to Yes.
    Expected result: SHFIN-01-A is available for new user sessions. [Elevated permissions required]

16. Start one AVD test session to SHFIN-01-A using the test account from Azure Virtual Desktop client.
    Expected result: Session remains connected for at least 5 minutes after sign-in.

17. Start a second AVD test session to SHFIN-01-A using a separate test sign-in.
    Expected result: Second session also remains stable for at least 5 minutes.

## 3) Verification
1. Open Azure Portal and go to Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts, then confirm SHFIN-01-A shows Available and Accepting new sessions = Yes.
   Expected result: SHFIN-01-A is online and accepting user sessions.

2. On SHFIN-01-A, open Event Viewer > Windows Logs > Application, then select Filter Current Log and set Event IDs to 1000 and Logged to Last 30 minutes.
   Expected result: No new Event 1000 entries show Faulting application name dwm.exe with Faulting module igdumd64.dll.

3. On SHFIN-01-A, open Event Viewer > Windows Logs > Application, then select Filter Current Log and set Event ID to 9009 and Source to Desktop Window Manager.
   Expected result: No new Event 9009 entries are present in the post-change window.

4. On SHFIN-01-A, open Event Viewer > Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational, then filter Event IDs 21 and 40.
   Expected result: Test sessions show Event 21 logon without near-immediate Event 40 disconnect.

5. In Azure Portal, open Azure Virtual Desktop > Host pools > POOL-FIN-01 > User sessions and verify two recent test sessions on SHFIN-01-A stayed connected for at least 5 minutes.
   Expected result: Two stable test sessions are visible with no rapid disconnect.

6. Confirm with affected users that logon is stable and check the ticket updates for no new disconnect reports in the next 15 minutes.
   Expected result: Users can work normally and no new incidents are reported.

## 4) Rollback
1. Open Azure Portal and go to Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts.
   Expected result: Session host list is visible.

2. Select SHFIN-01-A and set Allow new sessions to No (drain mode).
   Expected result: SHFIN-01-A immediately stops receiving new user sessions. [Elevated permissions required]

3. Select SHFIN-01-A and set Status to Unavailable (or Disable host if shown in your portal view).
   Expected result: SHFIN-01-A is removed from active service immediately. [Elevated permissions required]

4. Open Azure Virtual Desktop > Host pools > POOL-FIN-01 > User sessions and verify no new sessions are assigned to SHFIN-01-A.
   Expected result: New sessions are landing only on remaining healthy hosts.

5. On SHFIN-01-A, open Event Viewer > Windows Logs > Application and export the current filtered incident evidence for Event IDs 1000 and 9009.
   Expected result: Evidence file is saved for escalation with exact timestamps.

6. Raise an escalation ticket to image/endpoint engineering and attach the Event Viewer export plus host name SHFIN-01-A.
   Expected result: Host is safely isolated within 3 minutes and engineering has actionable evidence.

## 5) Notes
- Incident signature from RCA: Event 1000 (dwm.exe faulting module igdumd64.dll) followed by Event 9009 and near-immediate session disconnect behavior.
- Comparison signal from unaffected host: SHFIN-02-A showed Event 9011 (DWM started successfully) and no Application Error events in the same window.
- Related incident context: issue appeared after overnight image update and affected multiple users on one host.
- Warning: Do not return SHFIN-01-A to user traffic until two successful test logons complete and no new Event 1000/9009 entries appear.
