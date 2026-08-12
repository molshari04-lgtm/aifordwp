# Adobe Acrobat Pro v23.6 Installation RCA

> **RCA status:** Provisional. The Acrobat installation error log was not available when this document was created. The timing and scope facts support a leading hypothesis but do not prove root cause.

## Incident statement

Adobe Acrobat Pro v23.6 installation began failing after an overnight image update. The failure is currently reported in one pool only; the start time, affected-host count, installer return code, and exact failing action remain to be confirmed from the installation log.

## Impact

- Acrobat Pro v23.6 cannot be installed successfully on affected devices in the updated pool.
- Users assigned to that pool may lack Acrobat functionality or receive repeated installation failures.
- Other pools are currently treated as comparison scope, not confirmed unaffected scope, until tested.

## Timeline

| Time or phase | Event |
|---|---|
| Before overnight update | Acrobat installation reportedly worked. |
| Overnight | Image update was applied to one pool. |
| After update | Acrobat Pro v23.6 installation failures were observed in that pool. |
| Investigation | Triage ranked pool/image-specific deployment or prerequisite changes highest; installer evidence is pending. |

## Evidence currently available

- The failure follows the overnight image update.
- The reported impact is limited to one pool.
- The available evidence does not include an Acrobat installer log, MSI return code, Intune Management Extension result, or detection-rule output.

## Provisional root-cause hypothesis

The overnight image update introduced a pool-specific change to the Acrobat deployment, installer package, installation context, or required prerequisite. That change causes the installation to fail in the updated pool while other pools use a different image or deployment state.

This is a hypothesis, not a confirmed root cause. The timing and pool boundary make it the leading explanation, but they do not distinguish between a changed package, missing prerequisite, security policy, pending servicing state, or assignment/context problem.

## Competing explanations

1. A prerequisite or Windows servicing regression was introduced by the image update.
2. A security control in the updated image blocked the installer or a child process.
3. The image update left devices in a pending-reboot or concurrent-installer state.
4. The pool's assignment, applicability, identity, execution context, proxy, or content path changed.
5. The Acrobat package or detection rule is faulty independently of the image update.

## Confirmation plan

1. Obtain the Acrobat installation log from one failed host and record the first failing action, exact error text, return code, and timestamp.
2. Compare the failed host with a known-good host from another pool: image version, Acrobat package hash/version, prerequisites, pending-reboot state, security controls, assignment, execution context, and management check-in.
3. Run the exact managed install command on one affected host while collecting installer, Windows Installer, Intune, and security-control events.
4. Test the same package and command on a controlled host using the pre-update image or a known-good pool image.
5. Confirm whether the failure reproduces across all hosts in the affected pool and whether it occurs outside that pool.

## Immediate containment

- Pause further rollout of the updated image or Acrobat deployment to additional pools.
- Keep a known-good Acrobat package and image available for a controlled comparison.
- Avoid repeated unattended retries until the installer return code and failure stage are captured.
- Provide an approved alternative Acrobat access path for users who are blocked, if operationally required.

## Corrective actions after confirmation

- If the image caused the fault, remove or repair the changed package, prerequisite, policy, or servicing state and redeploy through a pilot host before wider rollout.
- If the Acrobat package or command caused the fault, correct the package, install command, return-code handling, or detection rule and retest on both affected and known-good images.
- Add a post-image-update Acrobat installation smoke test for each pool before production release.
- Record image version, package hash, installer command, execution context, and detection result in the change record.
- Close the RCA only when the fix succeeds on a representative affected host and the same failure cannot be reproduced under the corrected configuration.

## Root-cause disposition

**Not yet confirmed.** Do not attribute the incident to Acrobat, Intune, the image update, or a security control until the installation log and controlled comparison identify the failing component.
