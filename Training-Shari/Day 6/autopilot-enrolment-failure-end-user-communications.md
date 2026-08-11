Audience 1 - Non-technical executive
A single-device migration issue has been resolved through the standard Intune recovery path. The affected user can now complete setup, and the root cause was a stale legacy enrolment record that conflicted with Autopilot. No broader platform outage was identified.

Audience 2 - Affected end-user (non-technical)
Your setup issue has been identified and fixed. Your device had an old company management record that blocked the new setup process. We have now cleared that record and prepared your device for setup again. Please follow the guided setup when prompted. If anything fails, contact the Service Desk and mention "Autopilot setup error 0x80180014".

Audience 3 - Engineer-to-engineer internal note
Confirmed RCA: stale legacy MDM enrolment on DESKTOP-FB099 caused Autopilot rejection (0x80180014). Profile failures (including 0x80070005) were downstream effects of missing valid enrolment context.

Actions completed:
1. Identified and deleted stale Intune enrolment record.
2. Confirmed Autopilot hash registration and profile assignment.
3. Performed wipe/reset and re-ran OOBE.
4. Verified successful Autopilot enrolment, profile application, and compliance progression.

Preventive controls:
- Add mandatory pre-flight enrolment-state check to migration runbook.
- Flag legacy-enrolled devices as dedicated migration track.
- Monitor Intune diagnostics/alerts for repeated 0x80180014 patterns.
