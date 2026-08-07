# RCA: FINBRIDGE\cthompson Login Failure

## Incident Summary
FINBRIDGE\cthompson was unable to log in beginning around 08:40 this morning. The issue was resolved at 09:09 AM after the suggested resolution was applied, and a verified interactive logon by cthompson then succeeded on DESKTOP-FB022.

## Impact
- Affected user: FINBRIDGE\cthompson
- Scope: One user only
- User impact: Interactive logon failure until resolution at 09:09 AM

## Supporting Evidence
### Failed logon sequence on DESKTOP-FB022
- 08:44:01 Event 4776: Domain controller attempted to validate credentials for FINBRIDGE\cthompson and returned 0xC000006A (wrong password).
- 08:44:03 Event 4625: Interactive logon failed for FINBRIDGE\cthompson with unknown user name or bad password.
- 08:44:28 Event 4625: Interactive logon failed again with unknown user name or bad password.
- 08:44:55 Event 4625: Interactive logon failed again with unknown user name or bad password.
- 08:44:56 Event 4740: FINBRIDGE\cthompson was locked out, with DESKTOP-FB022 listed as the caller computer.
- 08:45:10 Event 4625: Unlock attempt failed because the account was locked out.
- 08:45:44 Event 4771: Kerberos pre-authentication failed for FINBRIDGE\cthompson with failure code 0x18 (wrong password) from source IP 10.10.8.112.
- 08:46:01 Event 4771: Kerberos pre-authentication failed again from source IP 10.10.8.112.
- 08:46:33 Event 4771: Kerberos pre-authentication failed again from source IP 10.10.8.112.

### Resolution evidence
- 09:08:14 Event 4722: FINBRIDGE\cthompson account was enabled by FINBRIDGE\helpdesk-admin.
- 09:09:01 Event 4624: FINBRIDGE\cthompson successfully logged on interactively from DESKTOP-FB022.

## Timeline
- 08:40:00: Login issue began.
- 08:44:01: Wrong-password validation failure recorded.
- 08:44:03 to 08:44:55: Multiple interactive logon failures recorded.
- 08:44:56: Account lockout recorded.
- 08:45:10: Unlock attempt failed because the account was locked.
- 08:45:44 to 08:46:33: Kerberos pre-authentication failures continued from source IP 10.10.8.112.
- 09:08:14: Account was enabled by FINBRIDGE\helpdesk-admin.
- 09:09:01: Successful interactive logon recorded from DESKTOP-FB022.

## 5 Why Analysis
### Problem statement
Why was FINBRIDGE\cthompson unable to log in?

1. Why did the user fail to log in?
- The account was locked out after repeated failed authentication attempts.

2. Why was the account locked out?
- Multiple bad password attempts were recorded for FINBRIDGE\cthompson.

3. Why were bad password attempts recorded?
- The security logs show repeated wrong-password and bad-password failures from DESKTOP-FB022 and source IP 10.10.8.112.

4. Why did the login start failing around 08:40?
- The failed attempts occurred in the incident window before the lockout was recorded at 08:44:56.

5. Why did service recover at 09:09 AM?
- The account was enabled at 09:08:14 and a successful interactive logon followed at 09:09:01.

## Root Cause
FINBRIDGE\cthompson was locked out after repeated wrong-password authentication attempts.

## Resolution
- The suggested resolution was applied.
- The account was enabled at 09:08:14 by FINBRIDGE\helpdesk-admin.
- A successful interactive logon was then recorded at 09:09:01 from DESKTOP-FB022.
- The issue was confirmed resolved at 09:09 AM.

## Preventive Action
1. Review the source of the bad attempts recorded from DESKTOP-FB022 and source IP 10.10.8.112.
2. Confirm the user is using the correct password before retrying sign-in.
3. Recheck sign-in logs after any retry to confirm failures stop and no further lockout occurs.
4. Monitor for repeat Event 4625, Event 4740, and Event 4771 entries for the same account.

## Closure Criteria
- cthompson can log in successfully.
- No further lockout events are recorded for the account.
- The account remains enabled and usable after verification.
