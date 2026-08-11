# Known Error Record: Autopilot Enrolment Fails with 0x80180014 (Device Already Enrolled)

Version: v1.0
Date: 11/08/2026
Status: Active

---

Symptom:
During Windows 11 Autopilot setup (OOBE), enrolment fails and the user cannot complete device setup. The diagnostic output shows error code 0x80180014.

Cause:
A stale legacy Intune MDM enrolment record already exists for the device. Autopilot attempts a new enrolment, but Intune rejects it because one active enrolment already exists.

Scope:
Any migration or re-provisioning scenario where a previously manually enrolled device is moved into Autopilot without clearing the old enrolment record first.

Workaround:
No user-side workaround. Retrying OOBE does not resolve this error.

Permanent fix:
Delete the stale Intune enrolment record, confirm the Autopilot device hash/profile assignment, wipe/reset the device, then run Autopilot again.

How to spot it:
- MDM diagnostic export shows ErrorCode: 0x80180014
- EnrollmentState: Failed
- Existing/legacy enrolment visible in Intune device records
- Downstream profile errors such as 0x80070005 may appear but are secondary

Routing guidance for Service Desk:
- Classify as known error: Autopilot enrolment conflict
- Escalate directly to Intune admin/L2-L3
- Do not ask user to repeatedly retry setup without admin-side remediation
