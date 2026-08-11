# KB (L2/L3): Autopilot Enrolment Fails with 0x80180014 (Device Already Enrolled)

Version: v1.0
Date: 11/08/2026
Status: Active

## Scope
Use this article when Autopilot/OOBE fails and the device cannot complete Intune enrolment, especially during Win11 migration or re-provisioning.

## Incident RCA
Confirmed cause in incident RCA-2024-0315-FB099:
A stale legacy MDM enrolment record (manual enrolment dated 2023-11-04) existed on DESKTOP-FB099. Autopilot enrolment was rejected with 0x80180014. Policy profile failures (including 0x80070005) and compliance non-evaluation were downstream effects.

## Evidence Pattern (What Confirms This RCA)
- MDM diagnostics show EnrollmentState: Failed and ErrorCode: 0x80180014.
- Intune shows existing/legacy enrolment for same device.
- Azure AD join, licensing, TPM/Secure Boot, and required enrollment endpoints are healthy.
- Configuration profiles show failed/not applied due to incomplete enrolment context.

## Technical Triage Workflow
1. Validate exact failure code from diagnostics or screenshot.
2. Confirm device presence and enrolment history in Intune All devices.
3. Identify legacy/manual enrolment record by enrolled date/type.
4. Confirm Autopilot hash and deployment profile assignment.
5. Check whether remote wipe is available or local reset is required.

## Resolution Steps
1. Delete stale Intune enrolment record (use Delete, not Retire).
2. Confirm device hash registration and Autopilot profile assignment.
3. Wipe/reset device:
   - Admin-center wipe if active record exists, or
   - Local reset to OOBE when remote command path is unavailable.
4. Re-run Autopilot with user sign-in.
5. Verify new enrolment record, profile success, and compliance progression.

## Verification Criteria
- New Intune record present with enrolment type Windows Autopilot.
- Deployment status completed successfully.
- Target configuration profiles show Succeeded.
- Compliance status advances to In grace period or Compliant.
- User can complete setup and access corporate resources.

## Escalation Boundary
Escalate to Intune platform/service owner when:
- 0x80180014 persists after stale record deletion and reset.
- Autopilot hash is missing/corrupted and import fails.
- Multiple devices in same wave fail with identical pattern.

Escalation package:
- MDM diagnostic export
- Intune device timeline/screenshots (before and after deletion)
- Autopilot profile assignment evidence
- User/device identifiers and timestamps

## Preventive Controls
- Mandatory pre-flight enrolment-state gate in migration runbook.
- Legacy-enrolled device audit before each migration wave.
- Alerting/monitoring for repeated 0x80180014 failures.
- L1 quick-routing guidance to avoid user retry loops.
