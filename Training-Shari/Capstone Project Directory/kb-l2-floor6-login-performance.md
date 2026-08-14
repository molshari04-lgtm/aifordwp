# Floor 6 Login and Performance Incident: Document Manager Rollback

**Version:** 1.0  
**Date:** 2026-08-14  
**Status:** Draft  
**Source:** `floor6-login-performance-runbook.md`

## Scope and trigger

Use this article when Floor 6 users report login failure, prolonged login, or poor workstation performance and the approved incident assessment identifies the Friday Document Manager deployment as the cause of sign-in resource contention. Timing alone is not sufficient. Confirm the incident evidence and approval before changing deployment state.

## Required authority and data

The operator must have Intune Administrator, Endpoint Manager Administrator, or a Configuration Manager role able to modify application deployments and collections. Incident/change approval is required.

Before execution, confirm:

- Document Manager package name, application ID, current version, and approved previous stable version/package.
- Intune Floor 6 Entra ID device group and Configuration Manager Floor 6 collection.
- Approved affected-device rollback group.
- Previous-package detection rule and, if needed, vendor-approved uninstall command or supersedence configuration.
- Affected device list and baseline sign-in/performance measurements.
- Whether Intune, Configuration Manager, or both enforce the deployment.

Do not invent a product code, uninstall command, or data-retention behavior.

## Intune execution

1. Navigate to `Intune admin center > Apps > All apps > [Document Manager] > Properties > Assignments > Edit`.
   **Expected result:** The Floor 6 required assignment is visible.
2. Under **Required**, remove `[Floor 6 Document Manager Ring]`, then choose **Review + save** and **Save**.
   **Expected result:** The assignment change succeeds and no other approved assignment changes.
3. Check `Apps > All apps > [Document Manager] > Monitor > Device install status`.
   **Expected result:** No additional Floor 6 devices receive the required app.
4. Deploy the approved previous package as **Required** to `[Floor 6 Document Manager Rollback]`, limited to affected devices.
   **Expected result:** Only the approved affected devices are targeted.
5. If removal is required, use approved Win32 supersedence or the approved uninstall package.
   **Expected result:** The current release is removed through the controlled package path.
6. Monitor the rollback package status and endpoint `IntuneManagementExtension.log`.
   **Expected result:** Test devices report the approved rollback state without unapproved install/uninstall errors.

Removing an assignment stops future required deployment but does not remove the installed app.

## Configuration Manager execution

1. Navigate to `Configuration Manager Console > Software Library > Application Management > Applications > [Document Manager]`.
   **Expected result:** The application and deployments are visible.
2. Open the deployment to `[Legal Floor 6 collection]`, choose **Delete**, and confirm assignment removal only.
   **Expected result:** The Floor 6 deployment is no longer enforced; installed apps remain installed.
3. Verify under `Monitoring > Deployments`.
   **Expected result:** The deployment is no longer targeted to the Floor 6 collection.
4. Confirm the approved previous package, commands, schedule, and user-experience settings.
   **Expected result:** Rollback inputs match the approved change record.
5. Deploy the approved rollback as **Required** to `[Floor 6 Document Manager Rollback]`.
   **Expected result:** Only affected devices receive the rollback.
6. Use vendor-approved uninstall deployment type or approved supersedence if removal is required.
   **Expected result:** Current-release removal and replacement are controlled and auditable.
7. Monitor `Monitoring > Deployments` and validate a small control set.
   **Expected result:** Install state is successful and sign-in duration, CPU/disk usage, and application errors return to baseline before expansion.

## Verification and closure evidence

- Confirm the current release is no longer assigned to the Floor 6 ring.
- Confirm the approved rollback state on test/control devices.
- Test sign-in with affected users or an approved Floor 6 account.
- Compare sign-in duration, CPU, disk usage, and application errors with baseline.
- Expand only after the control set passes and monitor for recurring Floor 6 incidents.
- Attach assignment/deployment status, affected device list, timestamps, endpoint logs, performance measurements, user confirmation, and approval to the incident.

Pass condition: affected users can sign in normally, performance is acceptable, and no recurring deployment-related error spike is observed.

## Rollback of this fix

If the rollback causes wider impact or removes required functionality:

1. Stop the rollback assignment/deployment.
   **Expected result:** No additional devices receive it.
2. Restore the last known working assignment state from the approved change record.
   **Expected result:** The prior configuration is ready to save.
3. Re-enable the prior approved version only for an approved recovery group, if incident command directs it.
   **Expected result:** Recovery targeting remains limited.
4. Save and verify the assignment in Intune or Configuration Manager monitoring.
   **Expected result:** Recovery is active without unintended Floor 6-wide targeting.
5. Test one recovery device for sign-in, CPU/disk, application launch, and required access.
   **Expected result:** Last-known-good behavior returns, or the failure is documented.
6. If unresolved, stop further changes and escalate with deployment status, sign-in timing, CPU/disk data, application errors, and relevant Intune Management Extension or Configuration Manager logs.
   **Expected result:** The incident is contained with actionable evidence.
