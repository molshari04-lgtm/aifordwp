# Adobe Acrobat Pro v23.6 Installation Triage

> **Status:** Provisional triage pending the Acrobat installation error log. The log was not available in the workspace, so no installer-specific error or exit code is being inferred here.
>
> **Scope clue used:** The failure began after an overnight image update and affects one pool only. This strongly weights pool/image-specific causes above tenant-wide or vendor-wide causes, but does not establish a root cause.

## Ranked likely causes

### 1. Image-specific package, installer, or deployment configuration change

**Why this fits the scope facts:** The overnight image update is the strongest timing clue, and the one-pool boundary points to a pool-specific image, application package, install command, detection rule, or configuration difference. A changed Acrobat package version or transform could cause every install attempt in that pool to fail while other pools remain healthy.

**Fastest check:** Compare the affected pool's image/package configuration and Acrobat installer hash or version with a known-good pool, then run the exact install command manually on one affected host.

### 2. Image-specific prerequisite or dependency regression

**Why this fits the scope facts:** The image update may have removed, changed, or left incomplete a prerequisite such as a required Visual C++ runtime, Windows component, licensing component, update level, disk state, or pending reboot condition. A shared image would reproduce the failure across the one pool.

**Fastest check:** On one affected host, review the installer log for the first prerequisite or dependency failure and compare installed prerequisite versions and pending-reboot state with a known-good host.

### 3. Security or policy change applied through the updated image

**Why this fits the scope facts:** A new security baseline, application-control rule, EDR policy, or controlled-folder restriction in the updated image could block the Acrobat installer or its child processes. The pool-only impact makes a shared local policy change plausible.

**Fastest check:** Correlate the installation timestamp with EDR, AppLocker, WDAC, or Windows security audit events on one affected host and check for a blocked Acrobat setup process.

### 4. In-use files, pending restart, or servicing-state conflict

**Why this fits the scope facts:** An overnight image update can leave the pool in a pending-reboot or Windows Installer servicing state. Acrobat installation may then fail because another installation is active, files are locked, or the servicing stack has not completed.

**Fastest check:** Check the Acrobat/Intune installer log and Windows Installer events for a concurrent-install or reboot-required condition, then verify the host's pending-reboot indicators.

### 5. Pool-specific assignment, identity, or installation-context issue

**Why this fits the scope facts:** The pool boundary could reflect a changed Intune assignment, device group, application applicability rule, SYSTEM-versus-user context, proxy configuration, or content download path rather than the Acrobat binaries themselves. The image update may have changed the device identity or management state used by deployment.

**Fastest check:** Compare application assignment, applicability, execution context, management check-in, and content-download status for one affected host against one working host in another pool.

## Working hypothesis

**The overnight image update introduced a pool-specific change to the Acrobat deployment or a required installation prerequisite, causing the install to fail consistently in that pool while other pools remain unaffected.**

This is the leading hypothesis because the failure began immediately after the image update and is bounded to one pool. It remains provisional: the error log must show a matching package, prerequisite, servicing, or deployment-context failure, and comparison with a known-good pool must reproduce the difference. If the same installer fails identically on an unaffected pool, or the affected pool has no relevant image or deployment difference, this hypothesis is weakened.

## What remains unconfirmed

The actual Acrobat error log is required to test these hypotheses against the installer-specific evidence, including the first failing action, return code, MSI error, prerequisite message, and whether failure occurred during detection, download, extraction, or execution. Do not designate a root cause until that evidence is reviewed.
