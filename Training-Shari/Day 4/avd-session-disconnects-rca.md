# RCA: AVD Session Disconnects on SHFIN-01-A

## Incident Summary
During the incident window on 2024-03-15, users connecting to AVD session host SHFIN-01-A experienced repeated session disconnects shortly after logon. The issue was resolved at 10:00 AM after the recommended resolution was applied. Verification showed users were logging in successfully to hosts in POOL-FIN-01 and no further issues were reported.

## Impact
- Affected platform: Azure Virtual Desktop
- Affected host: SHFIN-01-A
- Affected users: At least FINBRIDGE\mlopez and FINBRIDGE\akapoor during the window provided
- User impact: Sessions disconnected immediately after logon, interrupting work and forcing reconnects

## Supporting Evidence
### SHFIN-01-A event log evidence
- 07:02:10 Event 21: Remote Desktop Services session logon succeeded for FINBRIDGE\mlopez.
- 07:02:16 Event 1000: dwm.exe faulted in igdumd64.dll.
- 07:02:17 Event 40: Session disconnected immediately after the crash.
- 07:02:18 Event 9009: Desktop Window Manager exited with code 0x40010004.
- 07:02:44 Event 21: Session logon succeeded again for the same session.
- 07:02:46 Event 1000: dwm.exe faulted again in igdumd64.dll.
- 07:02:47 Event 40: Session disconnected again.
- 07:03:01 Event 9009: Desktop Window Manager exited again.
- 07:03:10 Event 21: Another reconnect succeeded.
- 07:08:22 Event 21: FINBRIDGE\akapoor logged on successfully.
- 07:08:24 Event 1000: dwm.exe faulted again in igdumd64.dll.

### Comparison host evidence
- SHFIN-02-A was unaffected during the same window.
- 07:01:44 Event 21: Session logon succeeded.
- 07:01:46 Event 9011: Desktop Window Manager started successfully.
- No Application Error events were recorded in the comparison window.

### Environmental evidence
- The host restarted after an overnight image update.
- The faulting module was igdumd64.dll, which indicates an Intel graphics driver-related crash path.
- The repeated crash pattern occurred on one host and affected more than one user session on that host.

## Timeline
- 02:03:11: Host rebooted after overnight image update.
- 07:02:10: FINBRIDGE\mlopez logged on successfully to SHFIN-01-A.
- 07:02:16: dwm.exe crashed in igdumd64.dll.
- 07:02:17: Session disconnected.
- 07:02:18: Desktop Window Manager exited.
- 07:02:44: Session reconnect succeeded.
- 07:02:46: dwm.exe crashed again in igdumd64.dll.
- 07:02:47: Session disconnected again.
- 07:03:01: Desktop Window Manager exited again.
- 07:03:10: Session logon succeeded again.
- 07:08:22: FINBRIDGE\akapoor logged on successfully.
- 07:08:24: dwm.exe crashed again in igdumd64.dll.
- 10:00:00: Recommended resolution applied and issue marked resolved.
- After 10:00: Verified users were logging in successfully to hosts in POOL-FIN-01 with no further issues reported.

## 5 Whys Analysis
### Problem statement
Why were AVD sessions disconnecting immediately after logon on SHFIN-01-A?

1. Why did the sessions disconnect?
- Desktop Window Manager crashed shortly after user logon.

2. Why did Desktop Window Manager crash?
- DWM faulted in igdumd64.dll, indicating a graphics driver failure path.

3. Why did the graphics driver failure appear after logon?
- The host had restarted after an overnight image update, and the crash appeared after the updated image loaded on the session host.

4. Why was the issue seen on this host and not the comparison host?
- SHFIN-01-A had the faulting image/driver combination, while SHFIN-02-A started DWM successfully and did not show Application Error events in the same window.

5. Why did the issue stop after remediation?
- The recommended resolution corrected the affected host condition, and users subsequently logged on successfully to POOL-FIN-01 with no further reports.

## Root Cause
A graphics stack problem on SHFIN-01-A caused Desktop Window Manager to crash in igdumd64.dll after the overnight image update. This produced immediate session disconnects after logon.

## Resolution
- The recommended resolution was applied.
- The host condition was corrected.
- The issue was confirmed resolved at 10:00 AM.
- Verification showed users logging in successfully to hosts in POOL-FIN-01 with no additional issues reported.

## Preventive Actions
1. Review the overnight image update process for graphics driver changes before rollout to production session hosts.
2. Validate the Intel graphics driver version and DWM startup stability on a pilot host after each image update.
3. Add event-log monitoring for repeated Event 1000 and Event 9009 combinations on AVD session hosts.
4. Compare updated hosts against a known-good baseline before returning them to user traffic.
5. Include a post-update smoke test with at least two test logons to confirm session stability before wider exposure.

## Closure Criteria
- Affected sessions no longer disconnect after logon.
- DWM no longer crashes on the session host.
- Users can log on successfully to POOL-FIN-01 hosts.
- No new related Application Error or DWM exit events are observed in the follow-up window.
