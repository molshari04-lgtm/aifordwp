# Adobe Acrobat Pro v23.6 Installation RCA

**Incident date:** 2024-03-15
**Scope:** One pool after an overnight image update
**Application:** Adobe Acrobat Pro v23.6
**RCA status:** Provisional, pending the verbose MSI installation log and host comparison

## Executive assessment

The most likely cause is a pool-specific installation-state or prerequisite change introduced by the overnight image update. The strongest technical candidate is an image-induced Windows servicing or installation conflict, such as a pending reboot, another installer transaction, locked files, or a changed prerequisite, causing `msiexec` to return generic MSI error `1603` under the SYSTEM context.

This is the leading cause, not a confirmed root cause. MSI return code `1603` means a fatal installation error but does not identify the failed MSI action by itself. The one-pool boundary and immediate post-image timing provide the strongest weighting evidence.

## Evidence from events

| Time | Event | Interpretation |
|---|---|---|
| 10:01:00 | AgentExecutor: Starting app install | Intune/application execution began normally. |
| 10:01:01 | Install context: SYSTEM | The install ran in the expected device context; this is not evidence of an interactive-user-only failure. |
| 10:01:02 | Package: `AdobeAcrobatPro.intunewin` | The assigned package was identified. |
| 10:01:03 | Command: `msiexec /i AcrobatPro.msi /quiet` | The MSI was launched silently; no interactive prompt was available to explain the failure. |
| 10:01:44 | Return code: `1603` | The MSI reported a fatal installation failure after approximately 41 seconds. The code is generic and requires the MSI log for the failing action. |
| 10:01:45 | Detection key not found | The specified registry key was absent after the failed attempt. This is consistent with no successful installation, but detection did not cause the preceding MSI failure. |
| 10:01:47 | App install result: Failed | The deployment engine recorded the failure. |
| 10:01:47 | Retry scheduled: 60 minutes | The system treated the result as retryable operationally. |
| 11:01:47 | Retry attempt 1 | The failure reproduced on retry rather than being a one-off transient event. |
| 11:01:48 | Same install command | No remediation or alternate package state was introduced before retry. |
| 11:02:31 | Return code: `1603` | The same fatal MSI result reproduced after approximately 43 seconds, strengthening the case for a deterministic host, image, package, or prerequisite condition. |

## What the events establish

- The failure occurs during MSI execution, before detection is evaluated.
- The failure is reproducible with the same command and package.
- The install is running as SYSTEM, so the investigation must include machine-wide prerequisites, servicing state, policy, permissions, and package access.
- The registry detection check reports `Not detected` after the failed attempt, which is expected if the product was not installed.
- The detection path targets `HKLM\\SOFTWARE\\Adobe\\Acrobat Reader\\23.0`, while the application is named Acrobat Pro v23.6. This may be an incorrect detection rule or a Reader/Pro product mismatch, but it does not explain the `1603` returned before detection.

## Most likely cause

**A pool-specific change from the overnight image update left the affected hosts in a state that prevents the Acrobat MSI from completing, most likely a pending-reboot, Windows Installer/servicing conflict, changed prerequisite, or related image configuration change.**

Why this ranks first:

1. The failure began after the image update.
2. Only one pool is affected, which points to a shared image or pool configuration rather than a tenant-wide Acrobat or Intune outage.
3. The failure is deterministic: the same silent SYSTEM command returns `1603` on both attempts.
4. The failure occurs during installation, not only during post-install detection.
5. The event data does not show a download or assignment failure; the package is selected and `msiexec` starts.

## Fastest confirmation check

On one failed host, collect the verbose MSI log for the exact command and inspect the first `Return value 3` and the preceding action. At the same time, compare the host with a known-good host from another pool for pending reboot indicators, Windows Installer activity, image version, installed prerequisites, free disk space, security blocks, and the Acrobat package hash.

A pending-reboot or servicing error in the MSI log, combined with a difference from the known-good pool, would support this cause. A package custom-action, permission, or missing-file error would redirect the RCA to that specific component.

## Five whys analysis

### Why 1: Why did the Acrobat deployment report Failed?

Because `msiexec /i AcrobatPro.msi /quiet` returned MSI error `1603` on the initial attempt and again on the retry.

**Evidence:** The `AppInstaller` events at 10:01:44 and 11:02:31 both report return code `1603`.

### Why 2: Why did the MSI return `1603`?

Because the MSI encountered a fatal installation condition before completing. The event excerpt does not identify whether that condition was a pending reboot, another installation, a prerequisite, a locked file, a blocked custom action, a permissions issue, or a package problem.

**Evidence:** The MSI was launched under SYSTEM and failed after 41 to 43 seconds, but no verbose MSI action log is provided.

### Why 3: Why is a host or image condition more likely than a transient installer fault?

Because the same package and same silent command reproduced the same failure approximately one hour later, and the issue is scoped to one pool after an overnight image update.

**Evidence:** The retry uses the same `msiexec /i AcrobatPro.msi /quiet` command and again returns `1603`; the reported scope is one updated pool.

### Why 4: Why would the overnight image update create a shared host condition?

An image update can change Windows servicing state, leave a pending restart, alter installed prerequisites, change machine policy or security controls, modify installer registrations, or change the packaged Acrobat content/configuration. Any of these changes can affect every host built from or assigned the updated image.

**Evidence:** The timing and pool boundary correlate with the image update. The specific changed component is not yet identified.

### Why 5: Why was the failure allowed to reach repeated production retries?

The deployment process appears to have retried a generic fatal MSI result without first collecting the verbose MSI log or applying a post-image installation smoke test. In addition, the detection rule appears to check an Acrobat Reader registry path for an Acrobat Pro application, creating a separate risk of false `Not detected` results after a successful install.

**Evidence:** Retry was scheduled 60 minutes after `1603`, the same command was run again, and detection checks `HKLM\\SOFTWARE\\Adobe\\Acrobat Reader\\23.0` for an app named Acrobat Pro v23.6.

## Contributing factors and separate defects

### Detection rule mismatch

The detection rule checks:

`HKLM\\SOFTWARE\\Adobe\\Acrobat Reader\\23.0`

The deployed application is identified as Adobe Acrobat Pro v23.6. Unless Pro deliberately writes this exact Reader key, the rule may be incorrect. This would cause a successful installation to be reported as `Not detected` and trigger unnecessary retries or repeated evaluation. It is a deployment defect to correct, but it is not the cause of the observed MSI `1603` because detection runs after the installer returns.

### Insufficient failure telemetry

The supplied events capture the return code but not the MSI verbose log, first failing action, custom-action output, or Windows event correlation. This prevents `1603` from being narrowed to a confirmed technical root cause.

### Retry without remediation

The retry repeats the same command and package after 60 minutes. That is unlikely to resolve a deterministic image or package condition and may generate noise while leaving the original failure unexplained.

## Immediate containment

1. Pause Acrobat deployment to additional devices using the affected pool image.
2. Stop automatic retries on a representative failed device until the MSI failure action is captured.
3. Preserve the affected image and package versions for comparison; do not overwrite the evidence before collecting logs.
4. Test one host from the affected pool and one known-good host using the same package and command.
5. Correct the detection rule separately after confirming the actual Pro installation footprint.

## Investigation and validation plan

1. Re-run the install on one affected host with verbose logging, for example using the approved deployment logging method for the environment.
2. Inspect the MSI log around the first `Return value 3`; record the preceding action, error text, custom action, file path, and any prerequisite or reboot message.
3. Review Windows Installer, Application, System, AppLocker/WDAC, and EDR events from 10:00 to 10:03 and the retry window.
4. Compare affected and known-good hosts for image build, reboot state, Windows Installer transaction, prerequisites, disk space, policy, package hash, and install context.
5. Test the pre-update image or known-good image with the same Acrobat package.
6. Replace the Reader-based detection rule with a validated Pro-specific detection rule, then verify Installed, Failed, and Not applicable outcomes on test devices.
7. Confirm successful install and correct detection on multiple representative hosts before resuming pool rollout.

## Corrective actions

| Action | Purpose | Completion evidence |
|---|---|---|
| Identify the MSI action behind `1603` | Establish the actual technical failure | Verbose MSI log with first `Return value 3` documented |
| Repair the image, prerequisite, servicing state, policy, or package identified by the log | Remove the failing condition | Successful install on an affected-pool test host |
| Validate the Acrobat Pro package and install command | Ensure package contents and command are correct | Package hash and command tested on known-good and affected images |
| Replace the detection rule with a Pro-specific rule | Prevent false `Not detected` results | Detection passes after installation and remains stable after restart |
| Add post-image Acrobat smoke testing | Catch pool-specific regressions before rollout | Test result recorded for each image/pool release |
| Gate retries on actionable MSI evidence | Avoid repeated identical failures | Retry policy or runbook requires log capture for repeated `1603` |

## RCA conclusion

The leading cause is a **pool-specific image or installation-state regression introduced by the overnight image update**, with a **pending reboot, Windows Installer/servicing conflict, or changed prerequisite** currently the most likely technical mechanism. The repeated SYSTEM MSI `1603` establishes a reproducible installation failure but is not specific enough to prove which mechanism is responsible.

The detection rule also appears mismatched to the Pro application and must be corrected, but it should be tracked as a separate deployment defect because the detection check occurs after the MSI failure. The RCA should remain open until the verbose MSI log and affected-versus-known-good comparison identify the failing component and a corrected deployment succeeds.
