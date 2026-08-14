# Runbook: Legal Floor 6 Missing Desktop Shortcuts

**Version:** 1.0  
**Date:** 2026-08-14  
**Status:** Draft  
**Source:** `missing-desktop-shortcuts-response.md` and `floor6-missing-desktop-shortcuts-rca.md`

## 1. Prerequisites

- Confirm the incident, affected user/device, exact missing shortcut name(s), expected target path(s), report time, and whether other users/devices are affected. Mark unknown values `to confirm`.
- Confirm the approved shortcut display name, executable target, working directory, icon path, affected scope, Document Manager package, Intune assignment/remediation, and Configuration Manager collection.
- Confirm whether the shortcut is shared through `C:\Users\Public\Desktop`, per-user, OneDrive-managed, or folder-redirection-managed. Do not write to user desktops from SYSTEM when ownership is per-user or redirected.
- Obtain incident/change approval before modifying assignments or deploying remediation.
- For endpoint restoration, have local administrator/SYSTEM capability. For Intune changes, use Intune Administrator or Endpoint Manager Administrator permissions. For Configuration Manager changes, use an authorized Configuration Manager role.
- Confirm the approved remediation script/package, detection rule, install command, and target collection/group.
- Have one approved affected device and one unaffected control device available for validation.
- Preserve the affected Desktop, Public Desktop, redirected/OneDrive Desktop, profile, deployment, and remediation evidence before changing state.

## 2. Procedure

### A. Stop further shortcut changes

1. In Intune, open `Intune admin center > Apps > All apps > [Document Manager] > Properties > Assignments > Edit`.
   **Expected result:** The Document Manager assignment editor shows the Floor 6 required deployment ring.
2. Remove `[Legal Floor 6 deployment ring]` from **Required**, select **Review + save**, then **Save**.
   **Expected result:** The Floor 6 required assignment is removed without changing unrelated assignments.
3. In Configuration Manager, open `Configuration Manager Console > Software Library > Application Management > Applications > [Document Manager]`.
   **Expected result:** The Document Manager application and its deployments are visible.
4. Open the deployment targeted at `[Legal Floor 6 collection]`, select **Delete**, and confirm deletion of the deployment assignment only.
   **Expected result:** The Floor 6 deployment assignment is removed; existing shortcuts are not restored and installed software is not automatically removed.

These actions stop new enforcement only. They do not restore shortcuts already removed or altered.

### B. Restore an approved shared shortcut

5. Confirm the shortcut is intended for every user and belongs in `C:\Users\Public\Desktop`.
   **Expected result:** The application owner or approved device confirms Public Desktop is the correct location and the target path exists or is expected to exist.
6. Package the approved restoration script as an Intune Win32 remediation/application deployment or Configuration Manager package. Use device/SYSTEM context.
   **Expected result:** The package contains only the approved shortcut values and has an approved detection rule.
7. Use the approved command with confirmed values:

```text
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\Restore-DocumentManagerShortcut.ps1 -ShortcutName "[Document Manager - to confirm]" -TargetPath "[confirmed executable path - to confirm]" -WorkingDirectory "[confirmed working directory - to confirm]" -IconLocation "[confirmed icon path - to confirm]"
```

   **Expected result:** The command is tied to the approved package and does not contain unresolved placeholder values.
8. Assign the Intune remediation/application as **Required** to `[Floor 6 affected devices]`, or deploy the Configuration Manager package as **Required** to the same approved device scope. For Configuration Manager, select **Whether or not a user is logged on** and **Run with administrative rights**.
   **Expected result:** Only the confirmed affected devices receive the restoration in device context.
9. Monitor the management-console deployment status and remediation logs.
   **Expected result:** The test device reports successful execution without install, detection, or permission errors.

### C. Correct the deployment and test

10. Correct or remove the confirmed shortcut-removal logic in `[Document Manager post-install script/package]`.
    **Expected result:** The package no longer contains the approved-to-remove shortcut behavior.
11. Update the Intune Win32 app or Configuration Manager application/package with the vendor-approved corrected version, detection rule, and install command.
    **Expected result:** The corrected deployment is ready for controlled testing.
12. Test the corrected deployment on one approved affected device and one unaffected control device.
    **Expected result:** Both devices complete the deployment without an unexpected shortcut change.
13. On the test device, verify the shortcut exists in `C:\Users\Public\Desktop` and opens the intended target.
    **Expected result:** The shortcut is visible to the user and launches the confirmed application or location.
14. Sign out and sign in, or process the relevant policy, then recheck the shortcut.
    **Expected result:** The shortcut remains present after sign-in or policy processing.
15. If the shortcut is per-user or OneDrive/Folder Redirection-managed, stop the SYSTEM deployment and route the correction to the policy/OneDrive owner.
    **Expected result:** The shortcut is restored only through its approved ownership context and no cross-profile change is made.

## 3. Verification

1. Confirm the current Document Manager assignment no longer targets the Floor 6 ring.
   **Expected result:** The package cannot newly enforce the confirmed shortcut-changing behavior.
2. Confirm the restoration deployment succeeded on each approved affected device.
   **Expected result:** Management status and detection state show the approved remediation completed.
3. Confirm the shortcut name, target path, working directory, icon, and desktop location match the approved baseline.
   **Expected result:** The shortcut is restored to the correct user, Public Desktop, or redirected location.
4. Have the affected user sign in and confirm the shortcut is visible and opens the intended application or location.
   **Expected result:** The user can use the shortcut successfully.
5. Recheck after sign-in or policy processing.
   **Expected result:** The shortcut does not disappear again.
6. Confirm whether any other Floor 6 users/devices are affected.
   **Expected result:** The incident scope is documented as confirmed or expanded.
7. Attach management-console output, remediation logs, shortcut inventory, target evidence, user confirmation, and before/after timestamps to the incident.
   **Expected result:** Closure evidence supports the exact action and verification result.

## 4. Rollback

Use rollback if the corrected deployment or restoration causes wider impact, creates an incorrect shortcut, or changes a desktop location that is not approved.

1. Stop or unassign the restoration/corrected deployment from the affected scope.
   **Expected result:** No additional devices receive the failing remediation.
2. Restore the last known-good assignment/package state from the approved change record.
   **Expected result:** The previous deployment configuration is ready to apply without broadening scope.
3. Do not delete a shortcut unless its ownership and removal are explicitly approved. If the shortcut is per-user, redirected, or OneDrive-managed, pause and route to that owner.
   **Expected result:** Rollback does not remove user-created or centrally managed content by assumption.
4. Apply the approved recovery assignment to one test device only, if directed by incident command.
   **Expected result:** Recovery behavior is limited and testable.
5. Sign in and validate the desktop location, shortcut visibility, target launch, and policy behavior.
   **Expected result:** The device matches the documented last-known-good state, or the failure is recorded.
6. Escalate with deployment status, shortcut inventory, profile/desktop paths, policy state, OneDrive/folder-redirection state, and remediation logs if the issue remains.
   **Expected result:** Further changes are paused and Endpoint Engineering has actionable evidence.

## 5. Safety notes

- The Friday deployment is a leading hypothesis, not a confirmed root cause until evidence proves the package or post-install behavior caused the shortcut change.
- Do not restore an unconfirmed shortcut target or use unresolved package values.
- A Public Desktop shortcut is appropriate only when the approved design is shared across profiles.
- A successful install status does not prove correct shortcut behavior; verify after sign-in or policy processing.
