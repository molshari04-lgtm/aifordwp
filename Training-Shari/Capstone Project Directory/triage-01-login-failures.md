# Triage Summary: Floor 6 Login Failures / Slow Logins

**Summary:** Roughly a dozen or more Floor 6 users are unable to log in or are experiencing very slow logins this morning.

**Impact:** At least ~12 users affected (to confirm exact count); entire floor appears involved. High business urgency — blocks work for a large group and is visible to leadership before lunch.

**Known facts:**
- Reported on Floor 6, this morning.
- At least a dozen people affected.
- Symptom is either inability to log in or very slow logins (two variants of the same complaint).
- A new document management application was rolled out to Floor 6 on Friday afternoon, shortly before this issue appeared.

**Missing information to gather:**
- Exact number of affected users and their usernames/devices (to confirm).
- Whether affected users are on-premises, VPN, or AVD/VDI (to confirm).
- Exact error message(s) or point of failure during login (to confirm).
- Whether login delay/failure started immediately after the Friday deployment or later (to confirm).
- Whether any Floor 6 users are unaffected, and what differs about their accounts/devices (to confirm).
- Any recent password, GPO, profile, or authentication (e.g., AD/Azure AD) changes tied to the rollout (to confirm).

**Likely category:** Authentication / login performance issue, possibly related to the Friday document management app rollout (e.g., new login script, GPO, profile change, or added service impacting sign-in). To confirm.

**Suggested first diagnostic step:** Pull sign-in/authentication logs and event logs for 2–3 affected Floor 6 devices to identify the exact failure point and timestamp, and correlate against the Friday deployment change record.
