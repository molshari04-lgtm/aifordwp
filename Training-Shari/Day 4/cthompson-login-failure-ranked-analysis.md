# Ranked cause analysis: cthompson login failure

Scope facts used: user cthompson cannot log in; cthompson is the only affected user; issue started around 08:40 this morning; no recent change.

## 1. Account lockout or bad password to confirm
Why this fits the scope facts: only one user is affected, which points first to an account-specific issue rather than a broader outage. A failure starting this morning with no reported change is consistent with repeated sign-in failures or a lockout.
Fastest check: Review the account status and sign-in/audit logs for lockout, bad password attempts, or temporary sign-in blocking.

## 2. Password expired or user must change password to confirm
Why this fits the scope facts: a single-user login failure with no other impact often comes from an account state problem. A password state change can present as a login failure without any wider service change.
Fastest check: Check whether the account shows password expired, must change at next sign-in, or similar status in the identity system.

## 3. MFA or conditional access block to confirm
Why this fits the scope facts: a sign-in problem affecting only one user can be caused by policy or verification failure rather than a device-wide issue. The lack of a change report keeps this open until sign-in policy results are checked.
Fastest check: Inspect the sign-in logs for MFA failure or conditional access denial for cthompson around 08:40.

## 4. Account disabled or sign-in blocked to confirm
Why this fits the scope facts: the issue is limited to one user, so an account status problem remains a strong possibility. This would also fit a sudden failure that begins at a specific time without a known change.
Fastest check: Confirm that the account is enabled and not blocked from sign-in.

## 5. Cached credential or profile issue on the user device to confirm
Why this fits the scope facts: if the problem is only for cthompson, the local device or profile may be holding stale sign-in data. The absence of a wider change keeps this lower than account-state causes, but it still fits a single-user failure.
Fastest check: Compare logon on another known-good device or profile for cthompson and check whether the same failure repeats.

Updated event details reviewed
- 08:44:01 Event 4776: Domain controller credential validation failed for FINBRIDGE\cthompson with error code 0xC000006A (wrong password) from DESKTOP-FB022.
- 08:44:03 Event 4625: Interactive logon failed for FINBRIDGE\cthompson on DESKTOP-FB022 with unknown user name or bad password.
- 08:44:28 Event 4625: Interactive logon failed again with unknown user name or bad password.
- 08:44:55 Event 4625: Interactive logon failed again with unknown user name or bad password.
- 08:44:56 Event 4740: User account locked out for FINBRIDGE\cthompson, caller computer DESKTOP-FB022.
- 08:45:10 Event 4625: Unlock attempt failed because the account was locked out.
- 08:45:44 Event 4771: Kerberos pre-authentication failed with failure code 0x18 (wrong password) from source IP 10.10.8.112.
- 08:46:01 Event 4771: Kerberos pre-authentication failed again from source IP 10.10.8.112.
- 08:46:33 Event 4771: Kerberos pre-authentication failed again from source IP 10.10.8.112.

Reviewed hypothesis
- The strongest surviving hypothesis is account lockout or repeated bad password attempts.
- The password-expired, MFA/conditional access, account-disabled, and cached-credential/profile explanations are weakened because the log entries consistently show wrong password and account lockout rather than those specific states.

Resolution summary
- Confirm the account is currently locked, then clear the lockout only after checking the source of the bad attempts.
- Check the originating sources shown in the logs: DESKTOP-FB022 between 08:44:01 and 08:44:56, and source IP 10.10.8.112 at 08:45:44, 08:46:01, and 08:46:33.
- Ask the user to verify the password and retry a clean sign-in on the normal device.
- If needed, reset the password and update any saved credentials on the device.
- Recheck sign-in logs after the user retries to confirm the failures stop and the account stays unlocked.
