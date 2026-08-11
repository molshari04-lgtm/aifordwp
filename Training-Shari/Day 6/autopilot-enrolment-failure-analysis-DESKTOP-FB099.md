# Autopilot Enrolment Failure – Root Cause Analysis & Remediation

**Device:** DESKTOP-FB099  
**User:** FINBRIDGE\rthomas  
**Analyst:** DWP Engineer  
**Date of Incident:** 2024-03-15  
**Date of Analysis:** 2026-08-11  
**OS Build:** Windows 11 22H2 (22621.2861)  
**Status:** Root cause confirmed — remediation steps defined  

---

## 1 – Scope Facts (from MDM Diagnostic Export)

- **Enrolment:** Failed. Error `0x80180014` — "The device is already enrolled in MDM."
- **Azure AD joined:** Yes
- **Existing MDM enrolment:** Yes — legacy manual enrolment dated 2023-11-04, still active
- **Policy application:** Failed. 0 of 4 profiles applied. Last error `0x80070005` (Access denied). Failed profile: `FinBridge-Win11-Security-Baseline`
- **Compliance evaluation:** Not performed — engine reported "Could not evaluate" because enrolment did not complete
- **Licensing:** Correct — M365, Intune P1, and Autopilot licences all present
- **Network connectivity:** Healthy — all three required endpoints reachable, no proxy detected

---

## 2 – Root Cause

**Error `0x80180014` — Conflicting existing MDM enrolment**

Autopilot requires the device to enrol into Intune as a fresh MDM-managed device. The device `DESKTOP-FB099` already holds an active MDM enrolment record from a legacy manual enrolment dated **2023-11-04**. When Autopilot attempted to create a new enrolment record, the MDM stack rejected it because the device is already registered — Windows enforces a one-enrolment-per-device rule for the same MDM authority.

This is the single root cause. All downstream failures flow from it:
- `0x80070005` (Access denied) on policy application — no valid enrolment context existed to receive profiles
- 0 of 4 profiles applied — policy engine had no enrolment to target
- Compliance evaluation skipped — engine correctly detected enrolment was incomplete

**Network, licensing, TPM, Secure Boot, and Azure AD join are all healthy and are not contributing factors.**

---

## 3 – Remediation Steps

### Correct Order of Operations

> **Do not reverse these steps.** Removing the device from Intune before wiping it leaves an orphaned Azure AD object. Wiping before removing from Intune leaves a stale Intune record that blocks re-enrolment.

```
Step 1 → Remove stale enrolment record from Intune (admin center)
Step 2 → Verify Autopilot profile is assigned and device hash is registered
Step 3 → Wipe and reset the device (device-side or admin center)
Step 4 → Allow Autopilot to run on first boot
Step 5 → Verify enrolment and policy application
```

---

### Step 1 – Remove the Stale MDM Enrolment Record from Intune
**Action type: Admin center only — no device access required**

1. Sign in to [https://intune.microsoft.com](https://intune.microsoft.com).
2. Navigate to `Devices > All devices`.
3. Search for `DESKTOP-FB099`.
4. If two records exist (the legacy enrolment and the failed Autopilot attempt), identify the legacy record by checking **Enrolled date** = `2023-11-04` and **Enrolment type** = `Device enrolment manager` or `Manual`.
5. Open the legacy device record.
6. Click **Delete** in the top action bar.
7. Confirm deletion when prompted.

> If only one record exists (the failed Autopilot attempt showing the 2023 enrolment), delete that record. The stale data is embedded in it.

**Do not retire — use Delete.** Retire sends a retire signal to the device (remove company data), which may not be appropriate if the device is mid-migration. Delete removes the Intune record only.

---

### Step 2 – Confirm Autopilot Device Hash Registration
**Action type: Admin center only**

1. Navigate to `Devices > Enrolment > Windows > Windows Autopilot devices`.
2. Search for `DESKTOP-FB099` by serial number.
3. Confirm the device hash is present and the **Profile status** column shows `Assigned` with profile `FinBridge-Autopilot-Standard`.
4. If the profile status shows `Not assigned`:
   - Navigate to `Devices > Enrolment > Windows > Deployment profiles`.
   - Open `FinBridge-Autopilot-Standard`.
   - Under **Assignments**, confirm the device or its group is included.
   - If the device hash is missing entirely, re-harvest it: run `Get-WindowsAutoPilotInfo` on the device and upload the CSV via `Devices > Enrolment > Windows > Windows Autopilot devices > Import`.

---

### Step 3 – Wipe and Reset the Device
**Action type: Choose one — admin center OR device-side**

**Option A — Remote wipe from admin center (preferred, no physical access required):**

1. Navigate to `Devices > All devices`.
2. Confirm the stale record has been deleted (Step 1). If a new record appeared from a partial Autopilot attempt, open it.
3. Click **Wipe** in the top action bar.
4. Leave **Retain enrolment state and user account** unticked.
5. Tick **Wipe device, and continue to wipe even if device loses power** for resilience.
6. Click **Wipe** to confirm.
7. The device will receive the wipe command on next check-in and reset to OOBE.

> If the device has no current valid enrolment record (fully deleted), remote wipe cannot be sent. Use Option B.

**Option B — Local reset (requires physical or remote desktop access to the device):**

1. On the device: `Settings > System > Recovery > Reset this PC`.
2. Select **Remove everything**.
3. Select **Local reinstall** (no cloud download required if the device is on Win11 already).
4. Follow prompts to confirm — the device will reset to OOBE.

---

### Step 4 – Allow Autopilot to Run on First Boot
**Action type: Device-side (physical access or user-guided)**

1. On first boot after reset, connect to a network with internet access.
2. Do **not** proceed past the region selection screen manually — Autopilot detection occurs here.
3. The device should display the organisation's branded Autopilot sign-in screen (FinBridge branding if configured in the deployment profile).
4. The user `rthomas` signs in with their corporate credentials (`rthomas@finbridge.org` or equivalent UPN).
5. Autopilot runs the provisioning sequence — device joins Azure AD, enrols in Intune, and applies the 4 profiles.

> If the Autopilot screen does not appear and the standard Windows OOBE displays instead, the device hash is not registered or the profile is not assigned. Return to Step 2.

---

### Step 5 – Verify Enrolment and Policy Application
**Action type: Admin center — no device access required**

1. Navigate to `Devices > All devices`.
2. Search for `DESKTOP-FB099`. A new record should appear with today's enrolment date and **Enrolment type** = `Windows Autopilot`.
3. Open the device record and select **Compliance** — wait for the status to show **Compliant** or **In grace period** (not *Not evaluated*).
4. Select **Configuration profiles** on the device blade — confirm all 4 profiles show **Succeeded** (not *Pending* or *Error*).
5. Confirm the failed profile `FinBridge-Win11-Security-Baseline` now shows **Succeeded**.
6. Navigate to `Devices > Enrolment > Windows > Windows Autopilot devices`, locate the device, and confirm **Profile status** = `Assigned` and **Deployment status** = `Completed successfully`.

**Verification passed when:** New enrolment record present, enrolment type = Autopilot, all 4 profiles succeeded, compliance status = Compliant or In grace period.

---

## 4 – Preventive Action for Other Devices with Legacy Enrolments

### Identify All Affected Devices Before Migration

Run this report in the Intune admin center before Autopilot is triggered for remaining devices:

1. `Devices > All devices`
2. Filter: **Enrolment type** = `Device enrolment manager` OR `Manual` (these are legacy non-Autopilot enrolments)
3. Export the list to CSV.
4. Cross-reference against your Autopilot migration scope list — any device appearing in both lists is at risk of `0x80180014`.

Alternatively, use the Microsoft Graph API or PowerShell to query enrolment type at scale:

```powershell
# Requires Microsoft.Graph.Intune module
Get-IntuneManagedDevice | Where-Object { $_.managementAgent -ne "mdmAndWindowsInformationProtectionPolicy" } |
    Select-Object deviceName, enrolledDateTime, managementAgent, enrollmentType |
    Export-Csv -Path "legacy-enrolments.csv" -NoTypeInformation
```

### Remediate Before Autopilot Triggers

For each identified legacy-enrolled device in the migration scope:

1. Delete the Intune device record **before** the device enters Autopilot OOBE — do not wait for the failure.
2. Confirm the Autopilot hash is registered and the profile is assigned.
3. Schedule the wipe/reset as a planned action with the end user, not as a reactive step.

### Add a Pre-Flight Check to the Migration Runbook

Add the following gate to the migration runbook for all future Autopilot deployments:

> **Pre-flight gate:** Confirm via Intune that the target device has **no existing MDM enrolment record** before triggering Autopilot. If an existing record is found, follow the stale enrolment removal procedure above before proceeding. Do not skip this check — `0x80180014` cannot be resolved from within the Autopilot flow itself.

---

## 5 – Incident Summary

| Field | Detail |
|---|---|
| Device | DESKTOP-FB099 |
| User | FINBRIDGE\rthomas |
| Incident date | 2024-03-15 |
| Error | `0x80180014` — device already enrolled in MDM |
| Root cause | Stale legacy MDM enrolment (2023-11-04) blocking Autopilot re-enrolment |
| Contributing factors | None — network, licensing, TPM, Secure Boot, Azure AD all healthy |
| Resolution | Delete stale Intune record → confirm Autopilot hash assigned → wipe device → re-run Autopilot |
| Preventive action | Pre-flight legacy enrolment check added to migration runbook for all remaining devices |
| Estimated remediation time | 30–45 minutes including device reset and re-provisioning |
| Physical access required | Yes — for local reset (Option B) or to supervise Autopilot OOBE sign-in |
