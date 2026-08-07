Symptom     : Users on SHFIN-01-A experienced AVD sessions disconnecting immediately after logon and reconnect attempts. The issue affected live sessions and interrupted access during the incident window.
Cause       : SHFIN-01-A had a host-side graphics stack crash after the overnight image update. DWM faulted in igdumd64.dll.
Scope       : The issue affected SHFIN-01-A and users logging on to that host, including FINBRIDGE\mlopez and FINBRIDGE\akapoor during the incident window. SHFIN-02-A was unaffected.
Workaround  : Apply the suggested resolution and move users to working hosts in POOL-FIN-01. Verification showed users were logging in successfully after 10:00 AM with no issues reported.
Permanent fix: Correct the affected host condition so the DWM crash no longer occurs, then return the host to service only after verification.
How to spot it: Look for Event 1000 showing dwm.exe faulting in igdumd64.dll, followed by Event 9009 for Desktop Window Manager exiting and Event 40 session disconnects. The comparison host showed Event 9011 with DWM started successfully and no Application Error events.
