# Known Error Record: AVD Session Disconnects After Logon (DWM / igdumd64.dll)

**Version:** v 1.0
**Date:** 07/08/2026
**Status:** Draft

---

**Symptom:**
Users connecting to an AVD session host are disconnected within seconds of logon, with the session reconnecting and immediately disconnecting again in a loop. No error message identifying the cause is shown to the user.

**Cause:**
A faulty Intel graphics driver (`igdumd64.dll`) applied during an overnight image update caused `dwm.exe` (Desktop Window Manager) to crash immediately after user sessions loaded on SHFIN-01-A. Each crash produced an immediate session disconnect.

**Scope:**
SHFIN-01-A in host pool POOL-FIN-01. Confirmed affected users: FINBRIDGE\mlopez and FINBRIDGE\akapoor. SHFIN-02-A and other hosts in POOL-FIN-01 were unaffected during the same window.

**Workaround:**
Place SHFIN-01-A in drain mode (set Allow new sessions to No) via Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts. Existing and new sessions will route to SHFIN-02-A and other healthy hosts, restoring user access immediately.

**Permanent fix:**
Remove the faulty Intel graphics driver from SHFIN-01-A, install the approved known-good driver version matching the SHFIN-02-A baseline, restart the host, and verify two stable test logons before returning the host to service.

**How to spot it:**
On the affected host, Event ID `1000` (Source: Application Error) in the **Application** log shows `Faulting application name: dwm.exe` and `Faulting module name: igdumd64.dll`, followed within seconds by Event ID `9009` (Desktop Window Manager exited) and Event ID `40` (session disconnect). The unaffected comparison host shows Event ID `9011` (Desktop Window Manager started successfully) with no Application Error events in the same window.
