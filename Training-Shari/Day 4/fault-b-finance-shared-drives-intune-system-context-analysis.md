Assessment of FAULT-B:

Most likely cause (verified): drive mapping was migrated from a user logon script to an Intune script running in SYSTEM context, and the script attempted UNC mapping before user credentials/session context were available.

Why this fits the evidence:
1. Script execution context mismatch:
- 08:00:02 Intune Management Extension shows script context = SYSTEM account.
- Original design expected USER context (from prior GPO logon script).

2. UNC path access failed at execution time:
- 08:00:03 warning: `\\finbridge-fs01\Finance` not accessible from SYSTEM context.
- 08:00:03 error: exit code 1, network name cannot be found.

3. Timing confirms race condition at logon:
- Script failure occurs at 08:00:03.
- Workstation service only reaches running state at 08:00:05.
- Script has no retry, so it fails permanently for that session.

4. Group Policy is healthy and not causal:
- 08:00:06 GroupPolicy Event 1500 success.

5. Drive letter assignment failed as downstream symptom:
- 08:00:07 Ntfs Event 98 warning for S: not assigned.

Scope:
- Affected: all Finance users (45 users) on DESKTOP-FB* devices in OU=Finance.
- Blast radius reason: same migrated script targeting all Finance endpoints.

Immediate recovery actions:
1. Stop failing SYSTEM-context assignment for `Map-FinBridgeDrives.ps1` in Intune.
2. Restore user-context mapping method (user logon script or user-context Intune remediation).
3. Trigger policy sync and have users sign out/sign in once.
4. Validate `S:` mapping appears and opens `\\finbridge-fs01\Finance`.

Preventive actions:
1. For drive mappings, enforce user-context execution standard in migration checklist.
2. Add pre-production test matrix: SYSTEM vs USER execution context behavior.
3. Add retry logic with delayed execution after logon/session readiness.
4. Add rollout ring (pilot OU) before broad Finance deployment.
5. Add monitoring for Intune script exit code spikes and failed drive-map events.
