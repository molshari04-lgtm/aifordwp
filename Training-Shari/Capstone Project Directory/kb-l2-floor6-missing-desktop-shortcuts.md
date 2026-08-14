# L2: Legal Floor 6 Missing Desktop Shortcuts

**Version:** 1.0  
**Date:** 2026-08-14  
**Status:** Draft  
**Source:** `floor6-missing-desktop-shortcuts-runbook.md`

## Scope and diagnostic boundary

Use this article when a Floor 6 user reports missing desktop shortcuts after the Windows 11/Intune transition and the Friday Document Manager deployment. The deployment-related shortcut change is a leading hypothesis, not a confirmed cause. The symptom may also involve the user profile, Desktop/Public Desktop location, Intune policy, OneDrive Known Folder Move, or folder redirection.

Do not restore an unconfirmed shortcut or infer that a deployment script caused the symptom from timing alone.

## Required evidence and authority

Before action, record the affected user, device, report time, exact missing shortcut list, screenshots if approved, expected target paths, and whether the shortcuts were user-created, application-created, or centrally deployed. Preserve Desktop, Public Desktop, redirected/OneDrive Desktop, profile, deployment, and remediation evidence.

Confirm the approved shortcut display name, executable target, working directory, icon path, affected scope, Document Manager package, Intune assignment/remediation, Configuration Manager collection, corrected package, detection rule, and install command.

Required permissions:

- Local administrator/SYSTEM for endpoint or Public Desktop restoration.
- Intune Administrator or Endpoint Manager Administrator for Intune assignment changes.
- Authorized Configuration Manager role for Configuration Manager deployment changes.
- Incident/change approval before execution.

## Procedure

1. In Intune, remove `[Legal Floor 6 deployment ring]` from **Required** at `Intune admin center > Apps > All apps > [Document Manager] > Properties > Assignments > Edit`, then **Review + save** and **Save**.
   **Expected result:** New required enforcement is stopped and unrelated assignments are unchanged.
2. In Configuration Manager, open `Configuration Manager Console > Software Library > Application Management > Applications > [Document Manager]`, delete the deployment to `[Legal Floor 6 collection]`, and confirm assignment removal only.
   **Expected result:** The Floor 6 deployment assignment is removed; this does not restore shortcuts or remove installed software.
3. Confirm the shortcut belongs on `C:\Users\Public\Desktop` and is shared across profiles.
   **Expected result:** The approved ownership model is Public Desktop and the target values are verified.
4. Package the approved restoration script as an Intune Win32 remediation/application or Configuration Manager package in device/SYSTEM context.
   **Expected result:** The package contains confirmed values and an approved detection rule.
5. Deploy using the approved command:

```text
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\Restore-DocumentManagerShortcut.ps1 -ShortcutName "[Document Manager - to confirm]" -TargetPath "[confirmed executable path - to confirm]" -WorkingDirectory "[confirmed working directory - to confirm]" -IconLocation "[confirmed icon path - to confirm]"
```

   **Expected result:** No unresolved placeholder remains in the execution command.
6. Assign/deploy as **Required** to `[Floor 6 affected devices]`; in Configuration Manager select **Whether or not a user is logged on** and **Run with administrative rights**.
   **Expected result:** Only the approved affected devices receive device-context restoration.
7. Monitor management status and remediation logs.
   **Expected result:** The test device reports successful execution and detection.
8. Correct or remove the confirmed shortcut-removal logic in `[Document Manager post-install script/package]`, then update the approved Intune or Configuration Manager package, detection rule, and install command.
   **Expected result:** The corrected package no longer removes or alters the approved shortcut.
9. Test on one affected device and one unaffected control.
   **Expected result:** Both complete deployment without unexpected shortcut changes.
10. Confirm the shortcut exists at `C:\Users\Public\Desktop`, opens the intended target, and remains present after sign-out/sign-in or relevant policy processing.
    **Expected result:** The shortcut is visible, functional, and persistent.
11. If ownership is per-user, OneDrive-managed, or folder-redirection-managed, stop SYSTEM remediation and route to the policy/OneDrive owner.
    **Expected result:** Restoration occurs in the correct context without cross-profile modification.

## Verification and closure

- Assignment/deployment no longer targets the Floor 6 ring for the shortcut-changing behavior.
- Restoration succeeded on every approved affected device.
- Shortcut name, target, working directory, icon, and location match the approved baseline.
- Affected user confirms visibility and successful launch.
- Recheck after sign-in or policy processing confirms persistence.
- Scope confirms whether other Floor 6 users/devices are affected.
- Incident contains console output, remediation logs, shortcut inventory, target evidence, user confirmation, and timestamps.

A closure-ready result requires the exact remediation, approval, executor, time, and verification to be recorded. Root cause remains unconfirmed unless package or endpoint evidence establishes it.

## Rollback

If the fix causes wider impact or an incorrect shortcut:

1. Stop/unassign the restoration or corrected deployment.
   **Expected result:** No additional devices receive the failing action.
2. Restore the approved last-known-good assignment/package state.
   **Expected result:** Prior configuration is ready without broad targeting.
3. Do not delete shortcuts without explicit ownership and removal approval; pause for per-user, redirected, or OneDrive-managed locations.
   **Expected result:** User-created or centrally managed content is not removed by assumption.
4. Test recovery on one device for desktop path, shortcut visibility, target launch, and policy behavior.
   **Expected result:** Last-known-good behavior returns or the failure is documented.
5. Escalate with deployment status, shortcut inventory, profile/desktop paths, policy state, OneDrive/folder-redirection state, and remediation logs.
   **Expected result:** Further changes are paused and the next engineer has actionable evidence.
