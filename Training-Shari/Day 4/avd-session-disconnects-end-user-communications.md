Audience 1 — Non-technical executive
Your access is working again. The issue on the AVD host was resolved at 10:00 AM, and users are now logging in successfully to POOL-FIN-01 with no issues reported. Please continue as normal.

Audience 2 — Affected end-user team (10 people, non-technical)
Your logon issue has been fixed. It was caused by a problem on one AVD host, and it was resolved at 10:00 AM. Users are now logging in successfully to POOL-FIN-01 with no issues reported. If you see the same issue again, let us know right away. Contact the service desk.

Audience 3 — Engineer-to-engineer internal note
Root cause: SHFIN-01-A had a host-side graphics stack crash after the overnight image update. DWM faulted in igdumd64.dll, then Event 9009 appeared and sessions disconnected immediately after logon.

Action taken: The suggested resolution was applied and the issue was marked resolved at 10:00 AM.

Config detail: The faulting module was igdumd64.dll on SHFIN-01-A. Comparison host SHFIN-02-A on the pre-update build showed DWM starting successfully and no Application Error events in the same window.

Verification: Users were logging in successfully to hosts in POOL-FIN-01 and no issues were reported after 10:00 AM.

Preventive action needed: Review the overnight image update path for graphics driver changes, validate Intel graphics driver/DWM stability on a pilot host after each update, monitor for repeated Event 1000 and Event 9009 combinations, compare updated hosts to a known-good baseline before returning them to service, and run at least two test logons before wider exposure.
