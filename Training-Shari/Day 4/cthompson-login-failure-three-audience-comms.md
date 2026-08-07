Executive:
Your access and data are safe. This morning, one user, cthompson, could not sign in from about 08:40 after repeated incorrect password attempts locked the account. The account was re-enabled at 09:08:14 by helpdesk-admin, and a successful sign-in was confirmed at 09:09:01 from the user device. The issue was resolved at 09:09 with no further issues reported. No action is needed from you.

Team:
Your access and data are safe, and this issue is resolved. This morning, one user (cthompson) could not sign in from about 08:40 because repeated incorrect password attempts locked the account; the account was re-enabled at 09:08:14 by helpdesk-admin, and sign-in succeeded at 09:09:01 from the user device. If you see the same issue, stop retrying and contact us immediately. Contact the DWP Service Desk.

Engineer:
Root cause: FINBRIDGE\cthompson account lockout after repeated wrong-password auth attempts.
Action taken: Suggested resolution applied; account re-enabled by FINBRIDGE\helpdesk-admin at 09:08:14 (Event 4722).
Config detail: Failure chain showed Event 4776 (0xC000006A wrong password), repeated Event 4625 bad-password interactive failures from DESKTOP-FB022, Event 4740 lockout, and Event 4771 pre-auth failures (0x18 wrong password) from source IP 10.10.8.112.
Verification: Event 4624 successful interactive logon for FINBRIDGE\cthompson at 09:09:01 from DESKTOP-FB022; issue marked resolved at 09:09; user verified working and no further issues reported.
Preventive action needed: Review bad-attempt sources DESKTOP-FB022 and 10.10.8.112, confirm correct password usage before retries, and monitor for repeat Event 4625/4740/4771 patterns for the account.
