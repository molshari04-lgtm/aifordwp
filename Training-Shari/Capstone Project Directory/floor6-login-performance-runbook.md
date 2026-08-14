# Runbook: Legal Floor 6 Login and Performance Fix

**Version:** 1.0  
**Date:** 2026-08-14  
**Status:** Draft  
**Source:** `login-performance-response.md`

## 1. Prerequisites

- Confirm Security/Endpoint evidence supports the working assumption that the Friday Document Manager deployment is causing Floor 6 sign-in resource contention.
- Obtain incident/change approval before changing an assignment or deploying a rollback.
- Use an Intune Administrator, Endpoint Manager Administrator, or Configuration Manager role with permission to modify application deployments and collections.
- Confirm the Document Manager package name, application ID, current version, Floor 6 Entra ID device group, Floor 6 Configuration Manager collection, approved previous stable package/version, detection rule, and approved rollback group. Do not proceed while these values remain unconfirmed.
- Identify affected Floor 6 devices and retain the before-change user/device list.
- Confirm whether the environment is managed through Intune, Configuration Manager, or both. Apply the matching procedure below.
- Have access to Intune app monitoring, Configuration Manager monitoring, and endpoint Intune Management Extension logs.
- Do not use an untested local uninstall command. The product code, uninstall command, and data-retention behavior must come from the approved package owner.

## 2. Procedure

### A. Intune: stop further assignment

1. Open `Intune admin center > Apps > All apps > [Document Manager] > Properties > Assignments > Edit`.
   **Expected result:** The Document Manager assignment editor opens and the Floor 6 required assignment is visible.
2. Under **Required**, remove `[Floor 6 Document Manager Ring]`.
   **Expected result:** The Floor 6 ring is marked for removal from the required assignment; no other approved assignments are changed.
3. Select **Review + save**, then **Save**.
   **Expected result:** Intune accepts the assignment change without error.
4. Open `Apps > All apps > [Document Manager] > Monitor > Device install status`.
   **Expected result:** No additional Floor 6 devices are receiving the required deployment.

Removing the assignment stops further required deployment. It does not remove the app already installed on affected devices.

### B. Intune: roll back affected devices

5. Confirm the approved previous stable package/version and detection rule.
   **Expected result:** The rollback package and detection rule match the approved change record.
6. Deploy the approved package as **Required** to `[Floor 6 Document Manager Rollback]`, containing only affected Floor 6 devices.
   **Expected result:** Only the approved affected-device group is targeted.
7. If removal is required, configure approved Win32 app supersedence to uninstall `[Document Manager current version]`, or assign the approved uninstall package to the rollback group.
   **Expected result:** Removal and replacement are controlled by the approved package; no generic local uninstall is used.
8. Monitor `Apps > All apps > [rollback package] > Monitor > Device install status` and the endpoint Intune Management Extension logs.
   **Expected result:** Test devices report the approved rollback state and no unapproved install or uninstall errors.

### C. Configuration Manager: stop further assignment

9. Open `Configuration Manager Console > Software Library > Application Management > Applications > [Document Manager]`.
   **Expected result:** The Document Manager application and its deployments are visible.
10. Open the deployment to `[Legal Floor 6 collection]`, select **Delete**, and confirm removal of the deployment assignment only.
    **Expected result:** The Floor 6 deployment assignment is removed; the installed application is not removed from devices.
11. Open `Monitoring > Deployments`.
    **Expected result:** The Document Manager deployment is no longer targeted to the Floor 6 collection.

### D. Configuration Manager: roll back affected devices

12. Confirm the approved previous stable application/package and its uninstall/install commands.
    **Expected result:** The rollback package and commands match the approved change record.
13. Create or use `[Floor 6 Document Manager Rollback]` with only affected devices.
    **Expected result:** The rollback collection contains the approved affected-device list.
14. Deploy the approved rollback application to that collection as **Required**, using the incident-approved schedule and user experience.
    **Expected result:** The rollback deployment is active only for the approved collection.
15. If removal is required, use the vendor-approved uninstall deployment type or approved supersedence.
    **Expected result:** The current release is removed only through the approved deployment configuration.
16. Monitor `Monitoring > Deployments`, then validate install state, sign-in duration, CPU/disk usage, and application errors on a small control set.
    **Expected result:** Control devices reach the approved rollback state and sign-in/performance measures return to baseline before expansion.

## 3. Verification

1. Confirm Intune or Configuration Manager no longer targets the Floor 6 ring for the current release.
   **Expected result:** No new Floor 6 device is assigned the problematic deployment.
2. Confirm the approved rollback package is installed on the test/control devices and the current release is removed where required.
   **Expected result:** Management status is successful and matches the approved rollback state.
3. Have affected users sign in, or test with an approved Floor 6 account.
   **Expected result:** Sign-in completes normally without the reported delay or failure.
4. Compare sign-in duration, CPU, disk usage, and application errors with the pre-incident baseline.
   **Expected result:** Workstation performance is acceptable and no new deployment-related errors appear.
5. Expand rollback only after the control set passes and continue monitoring the affected population.
   **Expected result:** No recurring Floor 6 spike in login or performance incidents is observed.
6. Record the action, approval, timestamps, affected devices, management-console status, endpoint logs, and user/device verification in the incident.
   **Expected result:** Closure evidence is complete and auditable.

## 4. Rollback

Use this section if the approved rollback causes wider impact, removes required functionality, or users remain unable to work normally.

1. Stop the rollback deployment or assignment for the affected rollback group.
   **Expected result:** No additional devices receive the rollback action.
2. Restore the last known working assignment state from the approved change record.
   **Expected result:** The previous deployment configuration is ready to be saved.
3. Re-enable the prior approved Document Manager version/package only for the approved recovery group, if directed by incident command.
   **Expected result:** Recovery targeting is limited to the approved devices.
4. Save the assignment/deployment change and verify it in the relevant monitoring view.
   **Expected result:** The recovery assignment is active without an unintended Floor 6-wide deployment.
5. Test one recovery device for sign-in, CPU/disk usage, application launch, and required business access.
   **Expected result:** The device returns to the documented last-known-good behavior, or evidence shows the rollback did not restore service.
6. If the device remains affected, stop further changes and escalate to Endpoint Engineering with the deployment status, sign-in timing, CPU/disk measurements, application errors, and relevant Intune Management Extension or Configuration Manager logs.
   **Expected result:** The incident is contained and the next engineer has actionable evidence.

## 5. Safety notes

- Removing an assignment stops future enforcement; it does not uninstall an already installed application.
- Use only the approved previous package, detection rule, uninstall command, and supersedence configuration.
- Expand a rollback beyond the control set only after verification and incident approval.
- The exact package, groups, collections, versions, commands, and approval references must be completed before execution.
