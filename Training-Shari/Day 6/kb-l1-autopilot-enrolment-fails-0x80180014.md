Version: v1.0
Date: 11/08/2026
Status: Active

# Autopilot Setup Fails with Error 0x80180014

## What this means
This usually means the device already has an old company management record. The setup cannot continue until an engineer clears that record in Intune.

## What L1 should do
1. Confirm the user is in Windows setup (Autopilot/OOBE) and cannot complete sign-in/provisioning.
2. Ask for the exact error code or screenshot.
3. If error is 0x80180014, do not continue local troubleshooting.
4. Raise and route to L2/L3 Intune support with high priority for onboarding delay.

## What to collect before escalation
- User name and contact details
- Device name/serial number (if visible)
- Error code screenshot (must show 0x80180014 if possible)
- Time issue started
- Whether this is a migration/new-build device

## What not to advise
- Do not ask user to keep retrying setup repeatedly.
- Do not advise local policy/network repair as primary fix.
- Do not close until L2/L3 confirms Intune-side remediation.

## Customer message template
"We can see this setup error is linked to a device management record conflict. We have escalated this to our Intune engineering team to clear and re-run setup safely. We will update you as soon as they confirm the device is ready to continue."