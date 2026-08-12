# Intune App Catalog – Step-by-Step Deployment Guide
## Adding and Deploying a Windows Application Before Phased Rollout

**Author:** DWP Engineer  
**Date:** 2026-08-11  
**Audience:** DWP engineers with no prior Intune app deployment experience  
**Worked Example:** FinBridge Connect v3.1 (.intunewin LOB app)  

> **Label variance notice:** Microsoft updates the Intune admin center UI regularly. Every navigation path and field label in this guide reflects a known-good version of the portal. Where labels are known to vary between tenant versions, this is flagged with ⚠️. Always verify the label you see in your own tenant before assuming the guide is wrong.

---

## Prerequisites

Before starting, confirm you have:

- [ ] Global Administrator or Intune Administrator role in the tenant
- [ ] The `.intunewin` package file built and available (see note below)
- [ ] Install and uninstall commands confirmed with the application owner
- [ ] Detection rule details confirmed (registry key, MSI product code, or file path)
- [ ] A pilot/test Azure AD group already created with 5–10 test devices enrolled

> **Building the .intunewin package:** If you have received a raw installer (`.exe` or `.msi`) but not a `.intunewin` file, you must wrap it first using the **Microsoft Win32 Content Prep Tool** (`IntuneWinAppUtil.exe`). Download from: `https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool`. Run: `IntuneWinAppUtil.exe -c <source folder> -s <setup file> -o <output folder>`. This guide assumes the `.intunewin` file is already built.

---

## Part 1 – Where to Add an App in Intune

### 1.1 Navigation Path

1. Sign in to [https://intune.microsoft.com](https://intune.microsoft.com).
2. In the left navigation panel, select **Apps**.
3. Select **All apps**.
4. Click **+ Create** in the top action bar.
5. In the right-side panel, keep **Platform** set to **Windows**, then choose the required **App type**.

⚠️ **Label variance:** In some tenant versions the top action may still appear as **+ Add** instead of **+ Create**. Both actions open the same app type selection panel.

---

### 1.2 Choosing the Correct App Type

When you click **+ Create** (or **+ Add**, depending on tenant version), a panel slides in from the right asking you to select an **App type**. Use the table below to choose correctly.

| What you are adding | App type to select | Notes |
|---|---|---|
| **A .intunewin packaged app** (LOB, custom installer, wrapped .exe or .msi) | **Windows app (Win32)** | This is the correct type for FinBridge Connect v3.1. Do **not** select "Line-of-business app" — that is for simple .msi files only and lacks detection rule support. |
| **A simple .msi with no wrapper** | Line-of-business app | Limited functionality — no custom detection rules, no requirement rules beyond OS version. Only use if the app is a straightforward .msi with no dependencies. |
| **A Microsoft Store app** | Microsoft Store app (new) | Searches the public Store catalog. Uses the new Store integration — no package upload required. ⚠️ Label may appear as "Microsoft Store app" without "(new)" in older tenants. |
| **A web link / bookmark** | Web link | Creates a browser shortcut pinned to the Company Portal or Start menu. No installation occurs. |

> For this guide, select **Windows app (Win32)** and click **Select**.

---

## Part 2 – Required Fields When Creating the LOB App

After selecting **Windows app (Win32)** and clicking **Select**, the creation wizard opens with multiple tabs. Work through each tab in order. Do not skip tabs — Intune will not let you save if mandatory fields are empty.

---

### 2.1 Tab: App information

This tab sets the identity and metadata for the app as it will appear in the Intune catalog and Company Portal.

#### Step 1 – Upload the app package

Click **Select file** next to the **App package file** field.

Browse to and select: `FinBridgeConnect_v3.1.intunewin`

Intune will upload and parse the file. When complete, the **Name** and **Publisher** fields may auto-populate from the package manifest. Verify them — they are often wrong or generic.

#### Step 2 – Complete App information fields

| Field | Value for FinBridge Connect | Notes |
|---|---|---|
| **Name** | `FinBridge Connect` | This is the display name shown in Company Portal. Keep it human-readable — no version number here unless required by your naming convention. |
| **Description** | `FinBridge Connect provides secure access to FinBridge internal systems. Required for all Finance department staff. Contact the service desk for access queries.` | Shown to end users in Company Portal. Write for users, not engineers. |
| **Publisher** | `FinBridge Ltd` | Must match the software vendor exactly if using publisher-based detection later. |
| **App version** | `3.1` | For display only — does not affect detection or update logic. |
| **Category** | `Business` (or your org's custom category) | Optional but helps users find the app in Company Portal. |
| **Show this as a featured app in the Company Portal** | Leave off for now | Enable only after pilot confirms the app is stable. |
| **Information URL** | Leave blank or add your internal KB URL | Optional. |
| **Privacy URL** | Leave blank or add vendor privacy policy | Optional. |
| **Notes** | `LOB deployment — FinBridge Connect v3.1. Pilot group assigned first. See RCA-2024-FINBRIDGE for deployment context.` | Internal notes visible to admins only, not to end users. |

Click **Next**.

---

### 2.2 Tab: Program

This tab defines how Intune installs and uninstalls the app, and what context it runs in.

| Field | Value for FinBridge Connect | Notes |
|---|---|---|
| **Install command** | `FinBridgeConnect_Setup.exe /silent` | Exact command Intune will execute. Must be silent — any interactive UI will cause the installation to appear to hang. |
| **Uninstall command** | `FinBridgeConnect_Setup.exe /uninstall /silent` | Run when assignment changes to Uninstall or device is removed from scope. |
| **Install behavior** | `System` | **System** installs as SYSTEM account — applies to all users on the device and does not require a user to be logged in. Use **User** only if the app installs per-user profile and the vendor explicitly supports it. FinBridge Connect is a system-wide install — use System. |
| **Device restart behavior** | `Determine behavior based on return codes` | Intune will read the exit code (see Return Codes section) to decide whether to restart. Do not force a restart unless the app vendor requires it. |
| **Return codes** | Configured in the next field group (see section 2.5) | |

⚠️ **Label variance:** In some tenant versions **Install behavior** appears as **Run as account** with values *System* and *User*. The meaning is identical.

Click **Next**.

---

### 2.3 Tab: Requirements

This tab defines the minimum device conditions that must be met before Intune will attempt to install the app. Devices that do not meet requirements will show **Not applicable** (not Failed).

| Field | Value for FinBridge Connect | Notes |
|---|---|---|
| **Operating system architecture** | `64-bit` | Select the architecture(s) the installer supports. Select both 32-bit and 64-bit only if the installer is genuinely universal. |
| **Minimum operating system** | `Windows 11 21H2` | Select the minimum Windows version. For a Win11-only deployment, set this to Windows 11 21H2 or later. Devices on Windows 10 will show Not applicable rather than Failed. |

**Additional requirement rules (optional but recommended):**

Click **+ Add** to add a custom requirement rule for disk space if the app is large:

| Requirement type | Rule |
|---|---|
| Disk space | Minimum free disk space: 500 MB (adjust to your app's actual size) |

Click **Next**.

---

### 2.4 Tab: Detection rules

Detection rules tell Intune how to determine whether the app is already installed on a device. This controls whether Intune installs, skips, or reports the app as installed.

**Rules format:** Select **Manually configure detection rules**.

Click **+ Add** and configure as follows for FinBridge Connect:

| Field | Value |
|---|---|
| **Rule type** | Registry |
| **Key path** | `HKEY_LOCAL_MACHINE\SOFTWARE\FinBridge\Connect` |
| **Value name** | `Version` |
| **Detection method** | String comparison |
| **Operator** | Equals |
| **Value** | `3.1` |
| **Associated with a 32-bit app on 64-bit clients** | No (FinBridge Connect is 64-bit) |

> **Why this detection rule matters:** If the detection rule is wrong, Intune will reinstall the app on every device check-in even after it has successfully installed. Always test the detection rule by manually checking the registry key exists on a device where the app has been installed before deploying to the pilot group.

**Alternative detection methods (not used here, for reference):**

| Method | Use when |
|---|---|
| **MSI product code** | The app is an .msi and you have the GUID from `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall`. Most reliable for .msi apps. |
| **File** | A specific file at a specific path is created by the installer (e.g., `C:\Program Files\FinBridge\Connect\FinBridgeConnect.exe`). Use version check if checking a file that might be present from an older version. |
| **Registry** | A registry key or value is written by the installer. Use this for apps that write a version string on install — as FinBridge Connect does. |

Click **Next**.

---

### 2.5 Tab: Dependencies (skip for this app)

Dependencies allow you to specify other apps that must be installed before this one. FinBridge Connect has no dependencies — click **Next**.

---

### 2.6 Tab: Supersedence (skip for this app)

Supersedence allows this app to replace an older version. If FinBridge Connect v2.x is already deployed, configure supersedence here to uninstall v2.x before installing v3.1. For a first-time deployment, leave blank and click **Next**.

---

### 2.7 Return Codes (within the Program tab)

Return codes define how Intune interprets the exit code returned by the installer. Standard defaults are pre-populated — do not remove them. Verify the following are present:

| Return code | Type | Meaning |
|---|---|---|
| `0` | Success | Installation completed successfully, no restart required |
| `1707` | Success | Installation completed successfully (MSI standard) |
| `3010` | Soft reboot | Installation succeeded but a restart is required to complete |
| `1641` | Hard reboot | Installation initiated a restart automatically |
| `1618` | Retry | Another installation is in progress — Intune will retry |

If the FinBridge Connect installer uses a non-standard success code (e.g., `2300`), confirm with the application owner and add it as a **Success** return code. Any exit code not in the list is treated as **Failed**.

---

### 2.8 Tab: Scope tags (optional)

Scope tags control which Intune admin roles can see and manage this app. If your organisation uses scope tags (e.g., by department or geography), apply the relevant tag here. For a standard DWP deployment with a single admin team, leave as **Default** and click **Next**.

---

### 2.9 Tab: Assignments

**Do not assign to the full fleet here.** Leave all assignment groups empty at creation time. Assignments will be made after the app is saved and verified in the catalog — see Part 3.

Click **Next**.

---

### 2.10 Tab: Review + create

Review every field against the values in this guide. Pay particular attention to:

- Install command is exactly `FinBridgeConnect_Setup.exe /silent` (no extra spaces or quotes unless needed)
- Uninstall command is correct
- Detection rule registry path and value name are correct
- Minimum OS version matches your fleet

Click **Create**.

Intune will upload the package and process it. This can take 2–10 minutes depending on file size. Do not navigate away. When complete, the app will appear in the **Windows apps** catalog with status **Ready**.

---

## Part 3 – Assignment Basics

### 3.1 Assignment Types Explained

Assignments control whether Intune installs, offers, or removes the app from devices in a group.

| Assignment type | What happens on the device | When to use |
|---|---|---|
| **Required** | Intune installs the app automatically in the background. The user does not need to do anything. If the app is not detected, Intune installs it on the next check-in. | Mandatory software that must be present on all devices in the group — security tools, corporate agents, line-of-business apps that users must have. |
| **Available (enrolled devices)** | The app appears in the **Company Portal** for the user to install voluntarily. Intune does not install it automatically. | Optional software the user can choose to install — productivity tools, optional utilities. |
| **Uninstall** | Intune removes the app from devices in the group if it is detected as installed. | Retiring an application, removing a version being superseded, removing software from a device group that should no longer have it. |

> **Important:** A device can receive conflicting assignments if it is in multiple groups. **Required** always wins over **Available**. **Uninstall** applied to a group takes effect even if another group has the app as **Required** — be precise with group membership to avoid unintended removals.

---

### 3.2 Why Always Assign to a Pilot Group First

> **Never assign a new app as Required to the full fleet as the first action.**

Assigning to 10,000 devices immediately carries these risks:

| Risk | Impact |
|---|---|
| Silent install failure (bad install command, missing dependency) | 10,000 failed install events simultaneously — all require remediation |
| Incorrect detection rule | Intune reinstalls the app on every check-in for all 10,000 devices — Intune becomes flooded with install attempts |
| App requires restart and restart behavior is misconfigured | 10,000 unexpected device restarts — potential data loss for users mid-session |
| App incompatible with a device model or driver version | Mass application failures with no pre-warning |

A pilot group of 5–20 devices absorbs all of these risks. Problems found in the pilot are fixed before any user on the wider fleet is affected.

---

### 3.3 Assigning to the Pilot Group

1. Navigate to `Apps > Windows > FinBridge Connect`.
2. Select **Properties** from the left-hand menu of the app blade.
3. Scroll to **Assignments** and click **Edit**.
4. Under **Required**, click **+ Add group**.
5. Search for and select your pilot group (e.g., `DWP-FinBridge-Pilot-Devices`).
6. Click **Select**, then **Review + save**, then **Save**.

Intune will begin deploying to devices in the pilot group on their next check-in (up to 8 hours, or trigger a manual sync).

**After pilot completes successfully**, return to Assignments and add the production group under **Required** — do not remove the pilot group.

---

## Part 4 – Verification Steps

### 4.1 Confirming the App Appears Correctly in the Catalog

1. Navigate to `Apps > Windows`.
2. Locate **FinBridge Connect** in the list.
3. Confirm:
   - **Name:** FinBridge Connect
   - **Platform:** Windows
   - **Type:** Win32
   - **Status:** Should show no error indicator. If it shows a warning icon, open the app and check the **Overview** tab for processing errors.
4. Click the app name to open it and select **Overview** — confirm the upload status shows no failures.

⚠️ **Label variance:** The **Overview** tab may be labelled **Monitor** or **App overview** in some tenant versions.

---

### 4.2 Checking Install Status on an Assigned Test Device

**Path — device-centric view:**

1. Navigate to `Devices > All devices`.
2. Open the test device record.
3. Select **Managed apps** from the device's left-hand menu.

⚠️ **Label variance:** This may appear as **App install status** or **Applications** in some tenant versions.

4. Locate **FinBridge Connect** in the list. The **Install status** column will show one of the states defined in section 4.3.

**Path — app-centric view (better for checking across all pilot devices):**

1. Navigate to `Apps > Windows > FinBridge Connect`.
2. Select **Monitor** > **Device install status**.
3. The list shows every assigned device with its current install status and any error detail.

---

### 4.3 Install Status Definitions

| Status | Meaning | Action required |
|---|---|---|
| **Installed** | The detection rule found the app on the device. Installation succeeded. | None — this is the target state. |
| **Not applicable** | The device does not meet one or more requirement rules (e.g., wrong OS version or architecture). The install was never attempted. | Review requirements rules. If the device should receive the app, adjust the rule or the group membership. |
| **Failed** | The installer ran but returned an unrecognised exit code, or the detection rule was not satisfied after install. | Click the device row to see the specific error code. Check the install command, uninstall command, and return codes. Check the Intune Management Extension log on the device: `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`. |
| **Pending** | The app has been assigned but the device has not yet checked in or the install has not yet been attempted. | Wait for the next check-in (up to 8 hours) or trigger a manual sync: `Settings > Accounts > Access work or school > [Account] > Info > Sync`. |
| **Not installed** | The app is assigned as Available but the user has not yet chosen to install it from Company Portal. | No action needed — this is expected for Available assignments. |

---

### 4.4 On-Device Verification (after Installed status confirmed)

Once the portal shows **Installed**, verify on the test device:

**Check the detection rule directly:**

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\FinBridge\Connect" -Name "Version" -ErrorAction SilentlyContinue |
    Select-Object Version
```

Expected output: `Version: 3.1`

If this returns nothing, the app installed but did not write the registry key — the installer behaviour does not match the detection rule. Re-examine the install command and consult the application owner.

**Check the application is functional:**

Launch FinBridge Connect from the Start menu or desktop shortcut and confirm it opens and connects successfully before signing off the pilot.

**Check the IME log for any warnings (even on success):**

```
C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log
```

Search for `FinBridgeConnect` in this log. A successful install will show `Installation succeeded with exit code 0`. Any warnings here should be noted even if the portal shows Installed.

---

## Part 5 – Phased Rollout After Pilot Sign-Off

Once the pilot group confirms:
- Status = **Installed** on all pilot devices
- Detection rule returns correct version value
- Application is functional
- IME log shows no warnings
- No unexpected restarts or failures

Proceed to phase 2:

1. Return to `Apps > Windows > FinBridge Connect > Properties > Assignments > Edit`.
2. Under **Required**, click **+ Add group** and add the next deployment ring group.
3. Monitor `Apps > Windows > FinBridge Connect > Monitor > Device install status` for 24 hours.
4. Repeat per ring until the full fleet is covered.

Do not add all rings simultaneously. Stagger by at least 24–48 hours per ring to allow monitoring between phases.

---

## Quick Reference Summary

| Task | Path |
|---|---|
| Add new app | `Apps > All apps > + Create` |
| Check app in catalog | `Apps > Windows > [App name] > Overview` |
| Assign to group | `Apps > Windows > [App name] > Properties > Assignments` |
| Check device install status (app view) | `Apps > Windows > [App name] > Monitor > Device install status` |
| Check device install status (device view) | `Devices > All devices > [Device] > Managed apps` |
| IME log (on device) | `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log` |
| Detection rule registry check | `Get-ItemProperty -Path "HKLM:\SOFTWARE\FinBridge\Connect" -Name "Version"` |

---

## References

- Win32 app deployment in Intune: `https://learn.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management`
- Microsoft Win32 Content Prep Tool: `https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool`
- Intune Management Extension logs: `https://learn.microsoft.com/en-us/mem/intune/apps/apps-win32-troubleshoot`
- App assignment types: `https://learn.microsoft.com/en-us/mem/intune/apps/apps-deploy`
