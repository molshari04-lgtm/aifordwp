# Root Cause Analysis – Autopilot Enrolment Failure
## DESKTOP-FB099 / rthomas / 2024-03-15

| Field | Detail |
|---|---|
| **RCA Reference** | RCA-2024-0315-FB099 |
| **Device** | DESKTOP-FB099 |
| **User** | FINBRIDGE\rthomas |
| **Analyst** | DWP Engineer |
| **Incident date** | 2024-03-15 |
| **RCA completed** | 2026-08-11 |
| **Severity** | Medium — single device, no data loss, user access delayed |
| **Status** | Root cause confirmed — remediation and preventive actions defined |

---

## 1 – Incident Summary

During a planned Windows 11 Autopilot migration, device `DESKTOP-FB099` failed to complete enrolment into Microsoft Intune. The Autopilot provisioning sequence halted with error `0x80180014`. Zero of four compliance and configuration profiles were applied. The user `rthomas` was unable to complete device setup and access corporate resources.

Investigation confirmed the failure was caused by a stale legacy MDM enrolment record from 2023-11-04 that was never removed prior to the migration attempt. The device had previously been enrolled manually outside of the Autopilot workflow and that record remained active in Intune at the time of the migration.

---

## 2 – Supporting Evidence

### 2.1 – MDM Diagnostic Export (collected 2024-03-15 09:22)

```
=== MDM Diagnostic Export ===
Device     : DESKTOP-FB099
User       : FINBRIDGE\rthomas
Date       : 2024-03-15 09:22
OS build   : 22621.2861

--- EnrollmentStatus ---
EnrollmentType    : Autopilot
EnrollmentState   : Failed
ErrorCode         : 0x80180014
ErrorDescription  : The device is already enrolled in MDM.
Timestamp         : 2024-03-15 09:18:44

--- PolicyManager ---
ProfilesAttempted : 4
ProfilesApplied   : 0
LastError         : 0x80070005 (Access denied)
FailedProfile     : FinBridge-Win11-Security-Baseline
Timestamp         : 2024-03-15 09:19:01

--- ComplianceEngine ---
EvaluationResult  : Could not evaluate
Reason            : Enrolment not complete
Timestamp         : 2024-03-15 09:19:45

--- DeviceInfo ---
AzureADJoined     : Yes
MDMEnrolled       : Yes (previous enrolment)
EnrolmentSource   : Legacy (manual MDM enrolment, 2023-11-04)
AutopilotProfile  : FinBridge-Autopilot-Standard
TPMVersion        : 2.0
TPMStatus         : Ready
SecureBoot        : Enabled

--- NetworkCheck ---
EndpointReach     : login.microsoftonline.com          : OK
EndpointReach     : enrollment.manage.microsoft.com    : OK
EndpointReach     : enterpriseregistration.windows.net : OK
ProxyDetected     : No

--- Licensing ---
M365LicenseFound  : Yes
IntuneP1License   : Yes
AutopilotLicense  : Yes
```

### 2.2 – Scope Facts Extracted from Evidence

| Fact | Value | Significance |
|---|---|---|
| Enrolment state | Failed | Autopilot sequence did not complete |
| Error code | `0x80180014` | Definitive — existing MDM enrolment conflict |
| Azure AD joined | Yes | Not a contributing factor |
| Existing MDM enrolment | Yes — 2023-11-04, legacy manual | **Direct cause of failure** |
| Profiles applied | 0 of 4 | Consequence of enrolment failure |
| Policy error | `0x80070005` Access denied | Consequence — no valid enrolment context |
| Compliance evaluation | Could not evaluate | Consequence — enrolment incomplete |
| Licensing | All valid | Not a contributing factor |
| Network | All endpoints reachable, no proxy | Not a contributing factor |
| TPM | v2.0, Ready | Not a contributing factor |
| Secure Boot | Enabled | Not a contributing factor |

### 2.3 – Error Code Reference

| Error | Meaning | Role in This Incident |
|---|---|---|
| `0x80180014` | The MDM server rejected enrolment because the device is already enrolled | **Root cause** |
| `0x80070005` | Access denied — the policy engine could not apply profiles because there was no valid enrolment session to target | **Downstream consequence** |

---

## 3 – Timeline

| Time | Event | Source |
|---|---|---|
| **2023-11-04** (est.) | Device `DESKTOP-FB099` manually enrolled into Intune via legacy MDM enrolment process outside of Autopilot workflow | MDM diagnostic: `EnrolmentSource: Legacy` |
| **2024-03-14** (est.) | Device added to Autopilot migration scope for Win11 rollout. No pre-flight check performed for existing enrolments. | Migration runbook (no pre-flight gate documented) |
| **2024-03-15 09:18:44** | Autopilot provisioning initiated on device at OOBE. User `rthomas` signs in. Enrolment request sent to Intune. | MDM diagnostic: `EnrollmentStatus` timestamp |
| **2024-03-15 09:18:44** | Intune rejects enrolment — `0x80180014`. Existing 2023-11-04 record conflicts with new Autopilot enrolment attempt. | MDM diagnostic: `ErrorCode` |
| **2024-03-15 09:19:01** | Policy manager attempts to apply 4 profiles. No valid enrolment context exists. All 4 fail with `0x80070005` (Access denied). | MDM diagnostic: `PolicyManager` timestamp |
| **2024-03-15 09:19:45** | Compliance engine attempts evaluation. Reports "Could not evaluate — Enrolment not complete." | MDM diagnostic: `ComplianceEngine` timestamp |
| **2024-03-15 09:22** | MDM diagnostic export collected. Device left at failed OOBE screen. User unable to access device. | MDM diagnostic: export timestamp |
| **2024-03-15** | Incident raised. DWP engineer assigned. MDM diagnostic reviewed. | Incident management system |
| **2026-08-11** | Root cause confirmed. RCA completed. Remediation steps and preventive actions documented. | This document |

---

## 4 – Five Why Analysis

**Problem statement:** Autopilot enrolment of `DESKTOP-FB099` failed with error `0x80180014` during a planned Win11 migration, leaving the device unprovisioned and the user unable to access corporate resources.

---

**Why 1 — Why did Autopilot enrolment fail?**

> Because Intune rejected the enrolment request with `0x80180014` — the device already had an active MDM enrolment record from 2023-11-04.

Windows enforces a single active MDM enrolment per device per authority. Autopilot cannot create a new enrolment record while an existing one is present. The rejection is by design — it is not a bug.

---

**Why 2 — Why was there an existing MDM enrolment record on the device?**

> Because the device was manually enrolled into Intune in November 2023 using the legacy MDM enrolment process, and that record was never removed before the device was added to the Autopilot migration scope.

The legacy enrolment was likely performed to bring the device under management temporarily (e.g., to push a policy or application) and was not formally offboarded when the Win11 migration programme was planned.

---

**Why 3 — Why was the stale enrolment record not removed before the migration attempt?**

> Because there was no pre-flight check in the migration runbook that required engineers to verify and clear existing MDM enrolment records before triggering Autopilot.

The migration runbook did not include a step to query Intune for devices with legacy enrolment types prior to adding them to the Autopilot scope. The assumption was that devices in scope were either unenrolled or would be handled automatically by the Autopilot process.

---

**Why 4 — Why was there no pre-flight check for existing enrolments in the runbook?**

> Because the migration runbook was authored without awareness that legacy manually enrolled devices would be included in the Autopilot migration scope, and the specific failure mode of `0x80180014` was not documented in the runbook as a known risk.

The runbook was written primarily for devices that were unenrolled (new builds or factory-reset devices). The population of legacy-enrolled devices was not identified or flagged as a separate category requiring additional pre-migration steps.

---

**Why 5 — Why was the population of legacy-enrolled devices not identified before the migration programme began?**

> Because no device enrolment audit was conducted at the start of the migration programme to categorise devices by enrolment type (Autopilot, manual MDM, unenrolled), and no acceptance criteria required proof of clean enrolment state before a device was admitted to the Autopilot migration scope.

Without an audit baseline, the migration team had no visibility of which devices carried legacy enrolment records that would conflict with Autopilot. The gap existed at programme planning level, not at individual engineer level.

---

### 5 Why Summary

```
Root cause (Why 5): No device enrolment audit at programme start
        ↓
Why 4:  Runbook authored without awareness of legacy-enrolled device population
        ↓
Why 3:  No pre-flight check in runbook to clear existing enrolments
        ↓
Why 2:  Stale 2023-11-04 legacy enrolment record not removed before migration
        ↓
Why 1:  Intune rejected Autopilot enrolment — 0x80180014
        ↓
Effect: Device unprovisioned, user unable to access corporate resources
```

---

## 5 – Immediate Remediation (for DESKTOP-FB099)

### Order of Operations

| Order | Step | Access Required |
|---|---|---|
| 1 | Delete stale enrolment record from Intune | Admin center only |
| 2 | Confirm Autopilot hash registered and profile assigned | Admin center only |
| 3 | Wipe and reset device | Remote wipe (admin center) or physical/RDP |
| 4 | User completes Autopilot OOBE sign-in | Device-side |
| 5 | Verify all 4 profiles applied and device is compliant | Admin center only |

### Step 1 – Delete Stale Enrolment Record
`Devices > All devices > DESKTOP-FB099 > Delete`

Identify the record by **Enrolled date** = 2023-11-04 and **Enrolment type** = Manual/Device enrolment manager. Use **Delete** (not Retire) — Retire sends a company data removal signal which is not appropriate here.

### Step 2 – Confirm Autopilot Hash and Profile Assignment
`Devices > Enrolment > Windows > Windows Autopilot devices`

Confirm **Profile status** = Assigned, profile = `FinBridge-Autopilot-Standard`. If not assigned, open the deployment profile and confirm the device's group is in scope.

### Step 3 – Wipe the Device
**Option A (no physical access):** `Devices > All devices > DESKTOP-FB099 > Wipe` — untick "Retain enrolment state", tick "Wipe even if device loses power".

**Option B (physical/RDP):** `Settings > System > Recovery > Reset this PC > Remove everything > Local reinstall`.

### Step 4 – Autopilot OOBE
Connect to internet on first boot. Autopilot sign-in screen should appear. `rthomas` signs in with corporate UPN. Provisioning completes automatically.

### Step 5 – Verification
`Devices > All devices > DESKTOP-FB099`

- Enrolment type = Windows Autopilot
- Enrolled date = today
- Configuration profiles: all 4 showing **Succeeded**
- Compliance: **Compliant** or **In grace period**
- `Devices > Enrolment > Windows > Windows Autopilot devices` — Deployment status = **Completed successfully**

---

## 6 – Preventive Actions

### PA-1 – Device Enrolment Audit Before Migration Scope Finalisation
**Owner:** Migration Programme Manager  
**Due:** Before next migration wave  

Run a full enrolment type audit across all devices in the migration scope:

```powershell
# Export all managed devices with enrolment type
Get-IntuneManagedDevice |
    Select-Object deviceName, enrolledDateTime, enrollmentType, managementAgent, userPrincipalName |
    Export-Csv -Path "enrolment-audit-$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation
```

Flag any device where `enrollmentType` is not `windowsAutoEnrollment` or `azureADJoinUsingDeviceTenantJoinedDevice`. These are candidates for `0x80180014`. Remove their Intune records before adding them to the Autopilot scope.

---

### PA-2 – Add Pre-Flight Gate to Migration Runbook
**Owner:** DWP Engineering Lead  
**Due:** Before next migration wave  

Insert the following mandatory check as a gate in the migration runbook, to be completed for every device before Autopilot is triggered:

> **Pre-flight gate — Enrolment State Check**
> 1. Search for the device in `Devices > All devices`.
> 2. Confirm no active enrolment record exists, OR that the existing record's enrolment type is `Windows Autopilot`.
> 3. If a legacy enrolment record exists: delete it, confirm deletion, and allow 15 minutes for the change to propagate before triggering Autopilot.
> 4. **Do not proceed to device wipe or Autopilot OOBE until this check is passed.**

---

### PA-3 – Categorise Legacy-Enrolled Devices as a Separate Migration Track
**Owner:** Migration Programme Manager  
**Due:** Programme planning review  

Devices with existing legacy enrolments require an additional step (enrolment record deletion) that is not in the standard Autopilot migration track. These devices should be:

- Tagged in the migration tracker with a `LEGACY-MDM` flag
- Assigned a dedicated engineer slot that accounts for the extra 15–30 minutes of admin center work
- Prioritised early in the migration schedule so they do not block other waves

---

### PA-4 – Configure Intune Alert for Enrolment Failures
**Owner:** DWP Infrastructure / Intune Admin  
**Due:** Within 2 weeks  

Create a monitor in Intune to alert on `0x80180014` failures so they are caught within 30 minutes rather than requiring a user-raised incident:

`Devices > Manage devices > Compliance > Monitor` — review the Enrolment failures report. For proactive alerting, configure a Log Analytics workspace connected to Intune Diagnostics and create an alert rule on error code `80180014`.

---

### PA-5 – Knowledge Article for L1/L2
**Owner:** Knowledge Management  
**Due:** Within 1 week  

Publish a known error record covering `0x80180014` so that service desk agents can identify and route these correctly without escalation delay:

- Symptom: Autopilot OOBE fails, user cannot complete device setup
- Quick check: MDM diagnostic shows `ErrorCode: 0x80180014`
- Action: Escalate to Intune admin — do not attempt local troubleshooting
- Do not ask the user to retry Autopilot without admin-side remediation first

---

## 7 – Lessons Learned

| # | Lesson | Application |
|---|---|---|
| 1 | Autopilot and legacy MDM enrolment are mutually exclusive — a device cannot hold both simultaneously | All future migration runbooks must include explicit enrolment state verification as a pre-condition, not a post-failure check |
| 2 | `0x80180014` is unrecoverable from within the Autopilot flow — the user cannot self-remediate and retrying will not help | L1 agents must be trained to escalate immediately rather than advising users to retry |
| 3 | The migration failure was not a technical defect — it was a process gap at programme planning level | Pre-migration audits and device categorisation must be mandatory programme entry criteria, not optional good practice |
| 4 | All downstream errors (`0x80070005`, compliance evaluation failure) were consequences of the single root cause | Investigating secondary errors before confirming the primary enrolment state is an inefficient diagnostic path — always check enrolment state first |

---

## 8 – Sign-Off

| Role | Name | Date |
|---|---|---|
| Analyst | DWP Engineer | 2026-08-11 |
| Technical reviewer | | |
| Programme manager | | |
