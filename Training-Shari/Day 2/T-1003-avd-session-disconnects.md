Summary (one line)
Azure Virtual Desktop session disconnects after roughly 10 minutes, then reconnects.

Impact (who/how many/ business urgency)
- Who: One user (to-verify).
- How many: One user affected based on current report.
- Business urgency: Disruptive to continuous work (urgency to-verify).

known facts
- AVD session disconnects after approximately 10 minutes.
- Session reconnects afterward.

Missing information to gather
- Network type/stability at time of disconnect (Wi-Fi, VPN, wired) (to-verify).
- Whether other AVD users are affected (to-verify).
- Client app/version used (to-verify).
- Any error/event shown on disconnect (to-verify).
- Whether this started recently or has always occurred (to-verify).

likely catagory
AVD session/network connectivity issue, possibly client-side network instability or session host timeout (to-verify).

First diagnostic step
Check the network connection stability (packet loss/latency) during a session and review AVD client-side logs or Event Viewer for disconnect reason codes.

Updated event details reviewed
- 07:02:10 Event 21: Session logon succeeded for FINBRIDGE\mlopez.
- 07:02:16 Event 1000: dwm.exe faulted in igdumd64.dll.
- 07:02:17 Event 40: Session disconnected immediately after the crash.
- 07:02:18 Event 9009: Desktop Window Manager exited.
- 07:02:44 Event 21: Reconnect succeeded for the same session.
- 07:02:46 Event 1000: dwm.exe faulted again in igdumd64.dll.
- 07:02:47 Event 40: Session disconnected again.
- 07:03:01 Event 9009: Desktop Window Manager exited again.
- 07:08:22 Event 21: Another user logon succeeded on the same host.
- 07:08:24 Event 1000: dwm.exe faulted again in igdumd64.dll.
- Comparison host SHFIN-02-A: 07:01:46 Event 21 logon succeeded, 07:01:46 Event 9011 DWM started successfully, no Application Error events.

Reviewed hypothesis
- The strongest surviving hypothesis is a host-side graphics stack crash on SHFIN-01-A, specifically DWM failing in igdumd64.dll after the overnight image update.
- The network-only explanation is weakened because the disconnects follow the host crash events immediately and repeat across users on the same host.
- The session-host-timeout explanation is also weakened because the disconnects align with DWM failures rather than a timed idle or policy timeout.

Resolution summary
- Confirm the issue scope on SHFIN-01-A and compare its image version and graphics driver set with SHFIN-02-A.
- Validate the Intel graphics driver state and confirm whether the crash began after the overnight update.
- Roll back or replace the graphics driver with a known-good version if the issue is tied to the update.
- Restart or drain/reimage the host if the DWM crash repeats after driver correction.
- Verify recovery by signing in a test user and confirming no new Event 1000 or Event 9009 entries appear.
