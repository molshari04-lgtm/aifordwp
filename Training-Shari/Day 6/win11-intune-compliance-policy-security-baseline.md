# Windows 11 Intune Compliance Policy – Security Baseline Translation

**Author:** DWP Engineer  
**Date:** 2026-08-11  
**Scope:** Windows 11 managed devices enrolled in Microsoft Intune  
**Grace Period:** 7 days applied to all settings  

---

## How to Apply Grace Period

In Intune, the grace period is set at the **compliance policy level**, not per setting.  
Navigate to:  
`Devices > Manage devices > Compliance > Policies > [Policy Name] > Properties > Actions for noncompliance`  
Set **"Mark device noncompliant"** action to **delay: 7 days**.

---

## Requirement 1 – BitLocker Must Be Enabled on the OS Drive

| Field | Detail |
|---|---|
| **Setting Name** | Require BitLocker |
| **Intune UI Path** | Devices > Manage devices > Compliance > Policies > Create policy > Windows 10 and later > System Security > Device Security > **Require BitLocker** |
| **Value** | Require |
| **Effect** | Enforces that BitLocker Drive Encryption is active on the OS (C:) drive. Devices without encryption are marked non-compliant and can be blocked from accessing corporate resources via Conditional Access. |
| **False-Positive Risk** | BitLocker may be fully enabled but the Intune report lags because the device has not yet completed a compliance check-in cycle after encryption finished. Also triggers on devices where BitLocker is suspended (e.g., post-BIOS update suspension that was not resumed). |
| **Recommendation** | Allow the 7-day grace period to absorb post-update suspension windows. Create a remediation script to auto-resume BitLocker after firmware updates: `Resume-BitLocker -MountPoint "C:"`. Confirm devices have completed at least one sync post-encryption before raising a non-compliance ticket. |

> ⚠️ **UI Change Flag:** The setting was previously listed under *Device Health* in older Intune portals. As of recent Intune releases it sits under *System Security > Device Security*. Verify path in your tenant at `intune.microsoft.com` as Microsoft periodically reorganises the compliance blade.

---

## Requirement 2 – Secure Boot Must Be Enabled

| Field | Detail |
|---|---|
| **Setting Name** | Require Secure Boot to be enabled on the device |
| **Intune UI Path** | Devices > Manage devices > Compliance > Policies > Create policy > Windows 10 and later > System Security > Device Security > **Require Secure Boot to be enabled on the device** |
| **Value** | Require |
| **Effect** | Validates that UEFI Secure Boot is active, preventing unsigned or malicious bootloaders from loading before Windows. Verified via Windows Health Attestation Service (HAS). |
| **False-Positive Risk** | Legacy BIOS devices (non-UEFI) physically cannot support Secure Boot — they will always flag non-compliant. Dual-boot configurations (e.g., Linux alongside Windows) typically require Secure Boot to be disabled. Some older hardware has Secure Boot capable but disabled by default from factory. |
| **Recommendation** | Before rollout, run a hardware audit: `Confirm-SecureBootUEFI` in PowerShell. Exclude known legacy-BIOS device groups via a dynamic AAD group scoped to a hardware model filter. Do not weaken the policy for the general population on account of a legacy minority — manage them separately. |

> ⚠️ **UI Change Flag:** This setting relies on the **Windows Health Attestation Service**. If Health Attestation reporting is not functioning in your tenant (common in air-gapped or proxy-restricted environments), this setting may return false non-compliance. Check HAS connectivity before enforcing.

---

## Requirement 3 – Minimum OS Build: N-1 (≥ 22621.2861)

| Field | Detail |
|---|---|
| **Setting Name** | Minimum OS version |
| **Intune UI Path** | Devices > Manage devices > Compliance > Policies > Create policy > Windows 10 and later > Device Properties > **Minimum OS version** |
| **Value** | `10.0.22621.2861` |
| **Effect** | Devices running an OS build older than Windows 11 22H2 build 22621.2861 are flagged non-compliant. This enforces the N-1 policy, ensuring devices are no more than one cumulative update behind the current known-good build (22621.3155). |
| **False-Positive Risk** | Windows Update rings with deferral policies may legitimately hold devices below this build during the deferral window. Devices awaiting a restart to complete update installation will report the old build until reboot. Newly enrolled devices in the out-of-box experience (OOBE) stage may not yet have updated. |
| **Recommendation** | Align the compliance minimum build with your Windows Update ring deferral schedule. If your update ring defers quality updates by 7 days, do not set the compliance minimum to the very latest build on day 1 of release — wait until the deferral window closes. Use the 7-day grace period to absorb restart-pending states. Review and update this value each Patch Tuesday. |

> ⚠️ **Build Number Note:** The values `22621.3155` (N) and `22621.2861` (N-1) were current as of training data. Verify the latest cumulative update build at [https://aka.ms/WindowsUpdateHistory](https://aka.ms/WindowsUpdateHistory) before enforcing. This setting **must be reviewed monthly**.

---

## Requirement 4 – Windows Defender Real-Time Protection Must Be On

| Field | Detail |
|---|---|
| **Setting Name** | Require real-time protection |
| **Intune UI Path** | Devices > Manage devices > Compliance > Policies > Create policy > Windows 10 and later > System Security > Microsoft Defender Antimalware > **Require real-time protection** |
| **Value** | Require |
| **Effect** | Enforces that Microsoft Defender Antivirus real-time protection (on-access scanning) is active. Devices with RTP disabled — whether by user action or third-party AV conflict — are marked non-compliant. |
| **False-Positive Risk** | Third-party AV solutions (e.g., CrowdStrike, Sophos) that are co-deployed may cause Defender to enter passive mode, which Intune can report as RTP off depending on the version and reporting method. Tamper Protection being enabled by a conflicting policy may also create inconsistent reporting. |
| **Recommendation** | If a third-party EDR is deployed, confirm whether Defender is intentionally in passive mode. If so, evaluate whether the third-party AV compliance is checked instead (many EDR vendors publish Intune compliance partner connectors). Do not enforce Defender RTP on devices where a certified third-party AV has taken primary responsibility unless your security policy explicitly requires both. |

> ⚠️ **UI Change Flag:** Microsoft has been consolidating Defender settings under the **Microsoft Defender for Endpoint** compliance connector in newer Intune builds. If your tenant uses the Defender for Endpoint connector (`Devices > Manage devices > Compliance > Policies > Microsoft Defender for Endpoint`), the setting path differs. Check which connector is active in your tenant.

---

## Requirement 5 – Firewall Must Be Enabled for All Profiles

| Field | Detail |
|---|---|
| **Setting Name** | Require Windows Firewall |
| **Intune UI Path** | Devices > Manage devices > Compliance > Policies > Create policy > Windows 10 and later > System Security > Windows Firewall > **Require Windows Firewall** |
| **Value** | Require |
| **Effect** | Validates that Windows Defender Firewall is enabled across all three network profiles: Domain, Private, and Public. Devices with the firewall disabled on any profile are marked non-compliant. |
| **False-Positive Risk** | Some legacy enterprise applications disable the Windows Firewall at install time and do not re-enable it. Third-party firewall software (e.g., Symantec Endpoint) may cause Windows to report its own firewall as off, even though network traffic is controlled. GPO conflicts pushing firewall-off settings will also cause false non-compliance. |
| **Recommendation** | Audit existing GPO and configuration profile settings for firewall policies before enforcing. If a third-party firewall is in use, verify whether Intune recognises it as satisfying this requirement (most do not — it checks the Windows Firewall service state specifically). Use a configuration profile to enforce firewall on rather than relying on compliance alone. |

---

## Requirement 6 – A PIN or Password Must Be Configured

| Field | Detail |
|---|---|
| **Setting Name** | Require a password to unlock mobile devices / Password required |
| **Intune UI Path** | Devices > Manage devices > Compliance > Policies > Create policy > Windows 10 and later > System Security > Password > **Require a password to unlock mobile devices** |
| **Value** | Require |
| **Supporting Settings** | Also configure: **Minimum password length** (recommended: 8), **Password type**: Alphanumeric or Device default, **Maximum minutes of inactivity before password is required**: 15 |
| **Effect** | Enforces that the device has a lock screen credential (PIN, password, or Windows Hello for Business) configured. Prevents unattended devices from being accessed without authentication. |
| **False-Positive Risk** | Shared kiosk devices or shared workstations deliberately configured without a password (auto-logon scenarios) will always flag non-compliant. Devices enrolled via Windows Autopilot that have not yet completed the full user-driven provisioning and Windows Hello setup may temporarily show no PIN configured. |
| **Recommendation** | Exclude kiosk/shared device groups from this compliance policy and manage them under a separate kiosk compliance profile with appropriate controls. For Autopilot devices, allow the 7-day grace period to cover the Windows Hello provisioning window post-enrolment. |

> ⚠️ **UI Change Flag:** The label *"Require a password to unlock mobile devices"* is historically carried over from mobile device management origins and applies to Windows PCs in this context. Microsoft has been updating label names in the Intune UI — verify the exact label in your tenant as it may now read *"Password"* or similar under the System Security blade.

---

## Requirement 7 – Device Must Not Be Jailbroken or Rooted

| Field | Detail |
|---|---|
| **Setting Name** | Device must not be jail broken or rooted |
| **Intune UI Path** | Devices > Manage devices > Compliance > Policies > Create policy > Windows 10 and later > Device Health > **Device must not be jail broken or rooted** |
| **Value** | Require |
| **Effect** | On Windows, this setting works in conjunction with the **Windows Health Attestation Service (HAS)** and **Microsoft Defender for Endpoint** to detect signs of OS integrity compromise — including boot integrity failures, code integrity violations, and Secure Boot bypasses. It is the Windows equivalent of jailbreak detection. |
| **False-Positive Risk** | Test/dev machines with custom kernels, unsigned drivers, or test-signing mode enabled will fail attestation. Devices where the HAS service cannot be reached (firewall blocks, proxy issues) may return inconclusive results that are treated as non-compliant. Hyper-V nested virtualisation environments can also affect attestation signals. |
| **Recommendation** | Ensure HAS endpoints are reachable from all managed devices: `has.spserv.microsoft.com`. Exclude development/test machines from production compliance policy scope where custom configurations are required. Where Defender for Endpoint is deployed, the threat signal from MDE provides a more reliable integrity signal than HAS alone. |

> ⚠️ **UI Change Flag:** On Windows 10/11, "jailbroken/rooted" detection is less prominent than on mobile platforms and the enforcement mechanism is entirely HAS-dependent. This setting may not appear in all Intune policy creation wizards depending on tenant configuration. If it is absent, the equivalent enforcement is achieved by combining **Secure Boot** (Req 2), **Code Integrity** (if available in your tenant), and the **Microsoft Defender for Endpoint compliance connector**.

---

## Step-by-Step: Creating the Policy in Intune

Use these steps to create and configure the compliance policy in one session. The path is confirmed from the live portal screenshot: **Devices > Manage devices > Compliance > Policies**.

### Step 1 – Open the Compliance blade
1. Sign in to [https://intune.microsoft.com](https://intune.microsoft.com) as a Global Admin or Intune Administrator.
2. In the left navigation, select **Devices**.
3. Under **Manage devices**, select **Compliance**.
4. Select the **Policies** tab.

### Step 2 – Create the policy
1. Click **+ Create policy**.
2. Set **Platform** to `Windows 10 and later`.
3. Click **Create**.

### Step 3 – Basics
| Field | Value |
|---|---|
| Name | `DWP-WIN11-Security-Baseline-Compliance` |
| Description | `Enforces DWP security baseline: BitLocker, Secure Boot, OS build N-1, Defender RTP, Firewall, PIN, integrity check.` |

Click **Next**.

### Step 4 – Compliance settings

Configure each section as follows:

#### Device Health
| Setting | Value |
|---|---|
| Require BitLocker | Require |
| Require Secure Boot to be enabled on the device | Require |
| Require code integrity | Require |
| Device must not be jail broken or rooted | Require |

#### Device Properties
| Setting | Value |
|---|---|
| Minimum OS version | `10.0.22621.2861` |

#### System Security – Password
| Setting | Value |
|---|---|
| Require a password to unlock mobile devices | Require |
| Password type | Alphanumeric |
| Minimum password length | 8 |
| Maximum minutes of inactivity before password is required | 15 |

#### System Security – Microsoft Defender Antimalware
| Setting | Value |
|---|---|
| Require real-time protection | Require |

#### System Security – Windows Firewall
| Setting | Value |
|---|---|
| Require Windows Firewall | Require |

Click **Next**.

### Step 5 – Actions for noncompliance (Grace Period)
1. The default action **Mark device noncompliant** is present at **Schedule (days after noncompliance)**: `0`.
2. Change the value from `0` to **`7`** to apply the 7-day grace period.
3. Optionally add a second action: **Send email to end user** at day `1` to notify users before enforcement.

Click **Next**.

### Step 6 – Assignments
1. Under **Included groups**, click **Add groups**.
2. Select your Windows 11 device group (e.g., `DWP-Win11-Managed-Devices`).
3. If kiosk or legacy-BIOS devices exist, add them to **Excluded groups** and manage them under a separate policy.

Click **Next**.

### Step 7 – Review + create
1. Review all settings against the summary table below.
2. Click **Create**.

### Step 8 – Link to Conditional Access (recommended)
For this policy to enforce access control, pair it with a Conditional Access policy:
1. Go to **Devices > Conditional access** (or **Entra ID > Protection > Conditional Access**).
2. Create a policy requiring **Compliant device** as a grant control.
3. Scope it to the same user/device group.

> The compliance policy alone marks devices non-compliant — it does **not** block access until a Conditional Access policy acts on that signal.

---

## Summary Table

| # | Requirement | Setting Name | Value | Grace Period |
|---|---|---|---|---|
| 1 | BitLocker on OS drive | Require BitLocker | Require | 7 days |
| 2 | Secure Boot enabled | Require Secure Boot to be enabled on the device | Require | 7 days |
| 3 | Minimum OS build ≥ 22621.2861 | Minimum OS version | 10.0.22621.2861 | 7 days |
| 4 | Defender RTP on | Require real-time protection | Require | 7 days |
| 5 | Firewall all profiles | Require Windows Firewall | Require | 7 days |
| 6 | PIN or password set | Require a password to unlock mobile devices | Require | 7 days |
| 7 | Not jailbroken/rooted | Device must not be jail broken or rooted | Require | 7 days |

---

## Settings Flagged for UI Verification

The following settings should be verified in your live Intune tenant before policy creation, as the UI paths or labels may have changed since training data:

| Setting | Reason to Verify |
|---|---|
| Require BitLocker | Path reorganised across Intune releases; may be under Device Security or Device Health |
| Require Secure Boot | Depends on Health Attestation Service availability in your tenant |
| Require real-time protection | May differ if Defender for Endpoint compliance connector is in use |
| Minimum OS version | Build numbers must be reviewed monthly against Patch Tuesday releases |
| Device must not be jail broken or rooted | May not appear in wizard; enforcement method differs between HAS and MDE |

---

## Post-Assignment Validation Steps

### 1 – Where to Find the Device's Compliance Status for This Specific Policy

**Path — device-centric view (recommended for a single test device):**

1. Go to `Devices > All devices`.
2. Search for the device by name or serial number and open it.
3. Select **Compliance** from the left-hand menu of the device blade.
4. You will see every compliance policy assigned to the device listed by name. Find `DWP-WIN11-Security-Baseline-Compliance`.
5. Click the policy name to expand the **per-setting breakdown** — each of the 7 settings is listed individually with its own pass/fail status and the reported value.

**Path — policy-centric view (recommended when checking across the fleet):**

1. Go to `Devices > Manage devices > Compliance > Policies`.
2. Click `DWP-WIN11-Security-Baseline-Compliance`.
3. Select **Monitor** (top tab row) > **Device compliance**.
4. Use the **filter** to narrow to a specific device, or review the aggregate compliant/non-compliant/in grace period counts.
5. Click any non-compliant device row to see which specific settings failed.

> **Tip:** After a device syncs, allow 5–10 minutes for the compliance evaluation to propagate to the portal. If the status still shows *Not evaluated*, trigger a manual sync from the device blade: **Sync** button in the device overview.

---

### 2 – Compliance State Definitions and Conditional Access Impact

| State | What It Means | Conditional Access Impact |
|---|---|---|
| **Compliant** | The device meets every setting in the policy at the time of the last evaluation. | CA grants access. The device is permitted to access cloud resources subject to other CA conditions (MFA, location, etc.). |
| **Not compliant** | One or more settings failed and the grace period (if any) has expired. | CA **blocks access** to any resource protected by a "Require compliant device" grant control. The user sees an error page directing them to the Company Portal to remediate. Access is blocked even if the user authenticates successfully. |
| **In grace period** | One or more settings failed, but the grace period clock (7 days) is still running. | CA **grants access** — the device is treated as compliant during the grace window. The user is not yet blocked. This is the window in which remediation should occur without user impact. |
| **Not evaluated** | The device has been assigned the policy but has not yet completed a compliance check-in. Common on newly enrolled devices or immediately after policy assignment. | CA behaviour depends on tenant configuration. Most tenants default to **blocking** unevaluated devices. Confirm your CA policy "Not compliant" handling under Grant controls. |

> **Key operational point:** "In grace period" provides no user disruption but is not the same as compliant. If a device remains in grace period without remediation and the clock expires, it transitions directly to "Not compliant" and CA blocks access with no further warning unless a notification action is configured.

---

### 3 – BitLocker False Positive: Three Most Common Causes and Fastest Checks

**Scenario:** Device shows non-compliant on "Require BitLocker" in Intune, but BitLocker appears to be running.

---

#### Cause 1 – BitLocker Is Suspended (Not Off, But Paused)

BitLocker enters a suspended state automatically after certain events: firmware/BIOS updates, Windows feature updates, and some driver installations. The OS drive remains encrypted but protection is paused — Intune reads this as non-compliant because the policy checks for *active* protection, not just encryption presence.

**Fastest check — run on the device locally or via Intune Remediations:**

```powershell
Get-BitLockerVolume -MountPoint "C:" | Select-Object MountPoint, VolumeStatus, ProtectionStatus
```

| ProtectionStatus | Meaning |
|---|---|
| `On` | Active — Intune should report compliant |
| `Off` | Suspended or disabled — this is the false positive cause |

**Fix:** `Resume-BitLocker -MountPoint "C:"` — protection resumes immediately; device will report compliant on next sync.

---

#### Cause 2 – Compliance Report Has Not Yet Refreshed After Encryption Completed

BitLocker may have finished encrypting after the last Intune compliance check-in. Intune is reporting a stale state — the device *was* non-compliant when last evaluated, but is now compliant. The portal has not caught up.

**Fastest check:**

1. On the device: confirm `ProtectionStatus` is `On` (command above).
2. In Intune portal: check **Last check-in time** on the device overview blade.
3. If the encryption completed *after* the last check-in timestamp, this is a stale report.

**Fix:** Force a sync from the Intune portal (device blade > **Sync**) or from the device: `Settings > Accounts > Access work or school > [Account] > Info > Sync`. Re-evaluate compliance after the next check-in completes (allow 10 minutes).

---

#### Cause 3 – Intune Cannot Read the BitLocker Status (Permissions / WMI Issue)

The Intune Management Extension or the compliance evaluation engine failed to query the BitLocker WMI provider (`Win32_EncryptableVolume`). This causes Intune to report the setting as failed rather than unknown, because it cannot confirm the required state.

**Fastest check — run on the device:**

```powershell
Get-WmiObject -Namespace "root\CIMV2\Security\MicrosoftVolumeEncryption" `
  -Class Win32_EncryptableVolume -Filter "DriveLetter='C:'" |
  Select-Object DriveLetter, ProtectionStatus, ConversionStatus
```

If this returns an error or empty result, the WMI provider is not responding correctly.

**Fix options:**
1. Re-register the WMI provider: `mofcomp.exe C:\Windows\System32\wbem\win32_encryptablevolume.mof`
2. Restart the Windows Management Instrumentation service: `Restart-Service winmgmt -Force`
3. If the device has recently been imaged or has a corrupted WMI repository, a full WMI repository rebuild may be required — this should be handled via a remediation script, not manually at scale.

---

#### BitLocker False Positive — Quick Reference

| Cause | On-Device Check | Fix |
|---|---|---|
| BitLocker suspended | `Get-BitLockerVolume C: | Select ProtectionStatus` → shows `Off` | `Resume-BitLocker -MountPoint "C:"` |
| Stale compliance report | Last check-in timestamp predates encryption completion | Force sync from portal or device; wait for re-evaluation |
| WMI provider failure | `Get-WmiObject Win32_EncryptableVolume` returns error | Re-register MOF or restart WMI service |

---

## References

- Intune compliance policies overview: `https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started`
- Windows Health Attestation Service: `https://learn.microsoft.com/en-us/windows/security/threat-protection/protect-high-value-assets-by-controlling-the-health-of-windows-10-based-devices`
- Windows 11 update history (verify current build): `https://aka.ms/WindowsUpdateHistory`
- Defender for Endpoint compliance connector: `https://learn.microsoft.com/en-us/mem/intune/protect/advanced-threat-protection`
