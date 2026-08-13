# Runbook: AVD Session Disconnects on SHFIN-01-A (DWM Crash Path)

## 1) Prerequisites
Complete this checklist before starting.

Access rights:
- [ ] Azure Portal access to the subscription and resource group hosting host pool `POOL-FIN-01`. [Elevated permissions required]
- [ ] Permission to change session host admission state (`Allow new sessions`) on `SHFIN-01-A`. [Elevated permissions required]
- [ ] Permission to mark a session host unavailable/disabled in AVD (if rollback is needed). [Elevated permissions required]
- [ ] Local administrator rights on `SHFIN-01-A`. [Elevated permissions required]
- [ ] Local administrator rights on comparison host `SHFIN-02-A`. [Elevated permissions required]

Tools and systems:
- [ ] Azure Portal is reachable.
- [ ] Remote Desktop Connection (`mstsc`) is available from your admin workstation.
- [ ] Event Viewer (`eventvwr.msc`) is available on both hosts.
- [ ] Device Manager (`devmgmt.msc`) is available on both hosts.
- [ ] Approved known-good Intel graphics driver package is available in internal software repository. [Elevated permissions required]

Mandatory incident information from end user/service desk:
- [ ] At least one affected username.
- [ ] First failure timestamp.
- [ ] Host name shown in client/session details (must include `SHFIN-01-A`).
- [ ] Screenshot or exact text of disconnect error.
- [ ] Confirmation whether disconnect occurs immediately after logon.
- [ ] Confirmation of at least one unaffected user/host (control comparison).

Change control:
- [ ] Active incident/change ticket ID is open and linked to this runbook execution.

## 2) Procedure
Perform steps in order. Each step is one action.

1. Open Azure Portal and navigate to `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts`.
Expected result: Session hosts list is visible.

2. Select `SHFIN-01-A`.
Expected result: Host details panel opens.

3. Set `Allow new sessions` to `No` for `SHFIN-01-A`. [Elevated permissions required]
Expected result: Drain mode is enabled on `SHFIN-01-A`.

4. Wait until the `Sessions` count for `SHFIN-01-A` is `0`.
Expected result: No active user sessions remain on `SHFIN-01-A`.

5. Open `mstsc` from your admin workstation.
Expected result: Remote Desktop Connection window opens.

6. Connect to `SHFIN-01-A` using local administrator credentials. [Elevated permissions required]
Expected result: Admin desktop session opens on `SHFIN-01-A`.

7. Open Event Viewer on `SHFIN-01-A`.
Expected result: Event Viewer console opens.

8. Navigate to `Event Viewer > Windows Logs > Application`.
Expected result: Application log is visible.

9. Click `Filter Current Log...` and set `Event IDs` to `1000`.
Expected result: Event 1000 entries are shown.

10. Confirm Event 1000 entries include `Faulting application name: dwm.exe` and `Faulting module name: igdumd64.dll`.
Expected result: Crash signature is confirmed.

11. In the same log, set `Event IDs` to `9009` and `Event sources` to `Desktop Window Manager`.
Expected result: DWM exit events are shown in incident window.

12. Navigate to `Event Viewer > Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational`.
Expected result: LSM operational log is visible.

13. Click `Filter Current Log...` and set `Event IDs` to `21,40`.
Expected result: Logon/disconnect sequence events are shown.

14. Confirm at least one Event `21` is followed by near-immediate Event `40`.
Expected result: AVD disconnect loop behavior is confirmed.

15. Open `mstsc` and connect to `SHFIN-02-A` using local administrator credentials. [Elevated permissions required]
Expected result: Admin desktop session opens on `SHFIN-02-A`.

16. Open Device Manager on `SHFIN-02-A`.
Expected result: Device Manager console opens.

17. Navigate to `Display adapters > Intel graphics adapter > Properties > Driver`.
Expected result: Known-good driver `Version` and `Date` are visible.

18. Record the known-good `Version` and `Date` from `SHFIN-02-A` in the incident ticket.
Expected result: Baseline driver values are documented.

19. Return to `SHFIN-01-A` and open Device Manager. [Elevated permissions required]
Expected result: Device Manager console opens on affected host.

20. Navigate to `Display adapters > Intel graphics adapter`.
Expected result: Intel adapter entry is selected.

21. Select `Uninstall device` on the Intel adapter. [Elevated permissions required]
Expected result: Uninstall dialog opens.

22. Enable `Delete the driver software for this device`. [Elevated permissions required]
Expected result: Delete-driver checkbox is selected.

23. Click `Uninstall`. [Elevated permissions required]
Expected result: Existing Intel driver package is removed.

24. Run the approved known-good Intel graphics driver installer from the internal repository. [Elevated permissions required]
Expected result: Installer completes successfully.

25. Restart `SHFIN-01-A` from `Start > Power > Restart`. [Elevated permissions required]
Expected result: Host reboots successfully.

26. Reconnect to `SHFIN-01-A` via `mstsc` as local administrator. [Elevated permissions required]
Expected result: Admin session opens after reboot.

27. Open `Device Manager > Display adapters > Intel graphics adapter > Properties > Driver` on `SHFIN-01-A`.
Expected result: Driver `Version` and `Date` are visible.

28. Confirm `SHFIN-01-A` driver `Version` and `Date` match `SHFIN-02-A` baseline.
Expected result: Driver baseline match is confirmed.

29. In Azure Portal, navigate to `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > SHFIN-01-A`.
Expected result: Host details are visible.

30. Set `Allow new sessions` to `Yes` for `SHFIN-01-A`. [Elevated permissions required]
Expected result: Host accepts new user sessions.

31. Start one test user session to `POOL-FIN-01`.
Expected result: Session remains connected for at least 5 minutes.

32. Start a second test user session to `POOL-FIN-01`.
Expected result: Second session remains connected for at least 5 minutes.

## 3) Verification
1. Open Azure Portal and navigate to `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts`.
Expected result: `SHFIN-01-A` status is `Available`.

2. Check `Accepting new sessions` for `SHFIN-01-A`.
Expected result: Value is `Yes`.

3. Open Event Viewer on `SHFIN-01-A` and navigate to `Windows Logs > Application`.
Expected result: Application log opens.

4. Filter Application log with `Event IDs: 1000` and `Logged: Last 30 minutes`.
Expected result: No new Event 1000 entries containing `dwm.exe` and `igdumd64.dll`.

5. Filter Application log with `Event IDs: 9009`, `Source: Desktop Window Manager`, `Logged: Last 30 minutes`.
Expected result: No new Event 9009 entries.

6. Navigate to `Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational`.
Expected result: LSM operational log opens.

7. Filter with `Event IDs: 21,40` and review test session timestamps.
Expected result: No near-immediate `21 -> 40` disconnect pair for test sessions.

8. Navigate to `Azure Virtual Desktop > Host pools > POOL-FIN-01 > User sessions`.
Expected result: Two recent test sessions show stable connected duration >= 5 minutes.

9. Confirm with affected users that production logons are stable.
Expected result: No new disconnect tickets within 15-minute observation window.

## 4) Rollback
Use rollback if disconnects continue, worsen, or new widespread impact starts after procedure.

1. Open Azure Portal and navigate to `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts`.
Expected result: Session hosts list is visible.

2. Select `SHFIN-01-A`.
Expected result: Host details panel opens.

3. Set `Allow new sessions` to `No`. [Elevated permissions required]
Expected result: No new users are routed to `SHFIN-01-A`.

4. Set host state to `Unavailable` (or `Disable` if shown in your portal). [Elevated permissions required]
Expected result: `SHFIN-01-A` is immediately removed from active routing.

5. Navigate to `Azure Virtual Desktop > Host pools > POOL-FIN-01 > User sessions`.
Expected result: No new sessions are assigned to `SHFIN-01-A`.

6. On `SHFIN-01-A`, open `Event Viewer > Windows Logs > Application`.
Expected result: Application log is visible.

7. Filter Application log with `Event IDs: 1000,9009` and `Logged: Last 1 hour`.
Expected result: Relevant post-change failure events are isolated.

8. Click `Save All Events in Filtered View As...` and save file as `SHFIN-01-A-postchange-1000-9009.evtx`.
Expected result: Evidence file is saved for engineering analysis.

9. Open incident ticket and attach saved `.evtx` plus screenshot of host state in Azure Portal.
Expected result: Escalation package is complete.

10. Escalate to image/endpoint engineering with subject `Rollback applied - SHFIN-01-A isolated from routing`.
Expected result: Host is safely isolated and Tier-3 can proceed without user impact spread.

## 5) Notes
- Incident signature from RCA: Event `1000` (`dwm.exe` fault in `igdumd64.dll`) followed by Event `9009`, with immediate user disconnects.
- Control comparison: `SHFIN-02-A` showed normal startup behavior (including Event `9011`) during the same period.
- Edge case: If both `SHFIN-01-A` and `SHFIN-02-A` show the same pattern, stop host-level remediation and escalate as potential image-wide regression.
- Warning: Do not return `SHFIN-01-A` to production routing until two successful 5-minute test logons are complete and no new Event `1000`/`9009` appears.
- Related incident context: Pattern started after overnight image update in the RCA timeline.
