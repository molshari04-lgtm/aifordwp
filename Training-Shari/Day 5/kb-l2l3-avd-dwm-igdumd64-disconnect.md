# KB Article: AVD Session Disconnects After Logon — DWM Crash (igdumd64.dll)

**Version:** v 1.0
**Date:** 07/08/2026
**Status:** Draft

---

## Background

Azure Virtual Desktop (AVD) delivers remote desktop sessions from session host VMs hosted in Azure. Each session host runs a full Windows OS and uses the Desktop Window Manager (DWM) process (`dwm.exe`) to render the graphical desktop that users see through the AVD client.

DWM depends on the graphics driver installed on the session host. In virtualised environments, Intel graphics drivers are commonly used. If the installed driver is faulty or incompatible with the current OS or image state, DWM will crash at or shortly after logon, causing the user's session to disconnect immediately.

This matters because:
- Finance and other business-critical teams rely on AVD as their primary desktop. A disconnect loop blocks all work.
- The failure can affect every user routed to that specific session host, not just one person.
- The failure is silent to the user — they see a generic disconnect, not a driver error — so incorrect diagnosis (password reset, account lock, network issue) is common without this article.

---

## Symptoms

### What users report
- Session closes immediately after logging in, sometimes after 2–5 seconds of seeing the desktop.
- The AVD client reconnects and the cycle repeats — the user cannot get a stable session.
- No error message identifying a specific fault; the client shows a generic "session ended" or "disconnected" message.
- The issue began suddenly — users could log in normally the day before.
- Multiple users from the same team (e.g., Finance) are affected at the same time.

### What the engineer observes
- Multiple tickets raised within a short time window, all describing the same disconnect-on-logon behaviour.
- All affected users are routed to the same session host (e.g., SHFIN-01-A) — users on other hosts (e.g., SHFIN-02-A) are unaffected.
- In Azure Portal under **Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts**, SHFIN-01-A may show a high churn of session connections and disconnections.
- The issue correlates with a recent image update or driver deployment to the affected host.

---

## Root Cause

**Specific cause:** A faulty or incompatible Intel graphics driver (`igdumd64.dll`) was applied to SHFIN-01-A during an overnight image update. The driver causes `dwm.exe` to crash immediately after a user session attempts to render the desktop. Each crash triggers an immediate session disconnect.

**Evidence that confirms it:**

| Evidence | Location | What it shows |
|---|---|---|
| Event ID 1000, Source: Application Error | Windows Logs > Application on SHFIN-01-A | `Faulting application name: dwm.exe`, `Faulting module name: igdumd64.dll` |
| Event ID 9009, Source: Desktop Window Manager | Windows Logs > Application on SHFIN-01-A | DWM exited — timestamps align with each user disconnect |
| Event ID 40, Source: TerminalServices-LocalSessionManager | Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational on SHFIN-01-A | Session disconnect events immediately following Event ID 21 logon events |
| Event ID 9011, Source: Desktop Window Manager | Windows Logs > Application on SHFIN-02-A (unaffected host) | DWM started successfully — confirms the fault is host-specific, not infrastructure-wide |
| Driver version mismatch | Device Manager > Display adapters > Intel graphics adapter > Properties > Driver on both hosts | SHFIN-01-A driver version/date differs from SHFIN-02-A known-good baseline |

---

## Detection

Complete all detection steps before taking any action. Each step must return a positive result before confirming this diagnosis.

Run the commands below from your admin workstation. `Invoke-Command` requires WinRM access to the session hosts. The Azure CLI commands require the `az` CLI authenticated to the correct subscription.

---

### Step 1 — Confirm scope is host-specific

**Portal path:** Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts

**Quick command (Azure CLI):**
```bash
az desktopvirtualization sessionhost list \
  --resource-group <RESOURCE-GROUP-NAME> \
  --host-pool-name POOL-FIN-01 \
  --query "[].{Host:name, Status:status, Sessions:sessions, AllowNewSession:allowNewSession}" \
  --output table
```

**What to look for:** SHFIN-01-A shows an unhealthy or degraded status or a high session churn count. SHFIN-02-A shows `Available` and normal session count. If both hosts show the same degraded state, this diagnosis does not apply — escalate.

**Positive result:** The fault is isolated to SHFIN-01-A. SHFIN-02-A is healthy.

---

### Step 2 — Confirm DWM crash on the affected host (Event ID 1000)

**Log:** Windows Event Log > **Application** log on SHFIN-01-A
**Source:** `Application Error`
**Event ID:** `1000`
**Fields to confirm:** `Faulting application name: dwm.exe` AND `Faulting module name: igdumd64.dll`

**Quick command (PowerShell — run from admin workstation):**
```powershell
Invoke-Command -ComputerName SHFIN-01-A -ScriptBlock {
    Get-WinEvent -FilterHashtable @{
        LogName   = 'Application'
        Id        = 1000
        StartTime = (Get-Date).AddHours(-4)
    } | Where-Object { $_.Message -like '*dwm.exe*' -and $_.Message -like '*igdumd64.dll*' } |
    Select-Object TimeCreated, Id, Message | Format-List
}
```

**Positive result:** One or more Event 1000 entries where the output contains both `dwm.exe` and `igdumd64.dll`. Timestamps must align with reported disconnect times.

---

### Step 3 — Confirm DWM exit events (Event ID 9009)

**Log:** Windows Event Log > **Application** log on SHFIN-01-A
**Source:** `Desktop Window Manager`
**Event ID:** `9009`

**Quick command (PowerShell):**
```powershell
Invoke-Command -ComputerName SHFIN-01-A -ScriptBlock {
    Get-WinEvent -FilterHashtable @{
        LogName   = 'Application'
        Id        = 9009
        StartTime = (Get-Date).AddHours(-4)
    } | Select-Object TimeCreated, Id, Message | Format-List
}
```

**What to look for:** Each Event 9009 timestamp must be within seconds of an Event 1000 entry from Step 2. This confirms DWM is exiting, not just logging a warning.

**Positive result:** Event 9009 entries are present and their timestamps match Event 1000 entries from Step 2.

---

### Step 4 — Confirm session logon/disconnect pattern (Event IDs 21 and 40)

**Log:** Windows Event Log > **Microsoft-Windows-TerminalServices-LocalSessionManager/Operational** on SHFIN-01-A
**Event ID 21:** Session logon (records user and session ID)
**Event ID 40:** Session disconnect (must follow Event 21 for the same session ID within seconds)

**Quick command (PowerShell):**
```powershell
Invoke-Command -ComputerName SHFIN-01-A -ScriptBlock {
    Get-WinEvent -FilterHashtable @{
        LogName   = 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'
        Id        = 21, 40
        StartTime = (Get-Date).AddHours(-4)
    } | Select-Object TimeCreated, Id, Message | Sort-Object TimeCreated | Format-List
}
```

**What to look for:** Pairs of Event 21 (logon) and Event 40 (disconnect) for the same session ID within 2–10 seconds, repeating across multiple users.

**Positive result:** The output shows a pattern of rapid 21→40 pairs confirming sessions are disconnecting immediately after logon.

---

### Step 5 — Confirm driver version mismatch (affected vs unaffected host)

**Quick command (PowerShell — queries both hosts simultaneously):**
```powershell
Invoke-Command -ComputerName SHFIN-01-A, SHFIN-02-A -ScriptBlock {
    Get-CimInstance Win32_PnPSignedDriver |
        Where-Object { $_.DeviceName -like '*Intel*' -and $_.DeviceClass -eq 'DISPLAY' } |
        Select-Object @{N='Host';E={$env:COMPUTERNAME}}, DeviceName, DriverVersion, DriverDate
} | Format-Table -AutoSize
```

**What to look for:** The `DriverVersion` or `DriverDate` value for SHFIN-01-A differs from SHFIN-02-A.

**Positive result:** SHFIN-01-A shows a different (newer or mismatched) driver version or date compared to SHFIN-02-A. Record both values — you will need SHFIN-02-A's version as the target to restore to in Resolution.

---

### Step 6 — Confirm SHFIN-02-A is healthy — definitive comparison check (Event ID 9011)

**Log:** Windows Event Log > **Application** log on SHFIN-02-A
**Source:** `Desktop Window Manager`
**Event ID:** `9011` — "Desktop Window Manager started successfully"

**Quick command (PowerShell):**
```powershell
Invoke-Command -ComputerName SHFIN-02-A -ScriptBlock {
    Get-WinEvent -FilterHashtable @{
        LogName   = 'Application'
        Id        = 9011
        StartTime = (Get-Date).AddHours(-4)
    } | Select-Object TimeCreated, Id, Message | Format-List
}
```

**What to look for:** Event 9011 entries on SHFIN-02-A confirming DWM started successfully during the same window where SHFIN-01-A is showing Event 9009 (DWM exiting).

**Positive result:** SHFIN-02-A returns Event 9011 (healthy); SHFIN-01-A returns Event 9009 (exiting) with no 9011 entries. This is the definitive comparison confirming the fault is isolated to SHFIN-01-A and is not an infrastructure-wide issue.

---

**All six steps positive? Proceed to Resolution. Any step negative or ambiguous? Do not proceed — re-examine scope or escalate.**

---

## Resolution

Complete all steps in order. Do not skip steps. Each step includes the exact portal/console path and expected result.

### Step 1 — Drain SHFIN-01-A

**Portal path:** Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > SHFIN-01-A

**Action:** Select SHFIN-01-A > click **…** (ellipsis) or Properties > set **Allow new sessions** to **No**.

**Expected result:** SHFIN-01-A shows drain mode enabled. No new user sessions are routed to this host.

---

### Step 2 — Wait for active sessions to clear

**Portal path:** Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts

**Action:** Monitor the **Sessions** column for SHFIN-01-A until it shows **0**.

**Expected result:** No active or disconnected sessions remain on SHFIN-01-A. Users have been rerouted to SHFIN-02-A or other healthy hosts.

---

### Step 3 — Connect to SHFIN-01-A as local admin

**Action:** From admin workstation, open Remote Desktop Connection (mstsc.exe), connect to SHFIN-01-A using local administrator credentials.

**Expected result:** Admin desktop session opens on SHFIN-01-A.

---

### Step 4 — Remove the faulty driver

**Console path:** Start > Device Manager > Display adapters > Intel graphics adapter > right-click > **Uninstall device**

**Action:** In the Uninstall Device dialog, check **Delete the driver software for this device**, then click **Uninstall**.

**Expected result:** The Intel graphics driver package is removed. Device Manager may briefly show a Basic Display Adapter. No error during uninstall.

---

### Step 5 — Install the approved known-good driver

**Action:** Access the internal software repository and retrieve the approved Intel graphics driver package. Run the installer on SHFIN-01-A.

**Expected result:** Driver installation completes without error. Device Manager > Display adapters shows the Intel graphics adapter restored with the correct driver.

---

### Step 6 — Restart SHFIN-01-A

**Action:** Start > Power > Restart on SHFIN-01-A.

**Expected result:** Host reboots cleanly and becomes reachable again via RDP within the expected boot window (typically 3–5 minutes for a session host VM).

---

### Step 7 — Verify driver version matches baseline

**Console path:** Device Manager > Display adapters > Intel graphics adapter > Properties > Driver tab on SHFIN-01-A

**Action:** Confirm the **Driver Version** and **Driver Date** match the values recorded from SHFIN-02-A in Detection Step 5.

**Expected result:** SHFIN-01-A driver version and date are identical to the SHFIN-02-A known-good baseline.

---

### Step 8 — Return SHFIN-01-A to service

**Portal path:** Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > SHFIN-01-A

**Action:** Set **Allow new sessions** to **Yes**.

**Expected result:** SHFIN-01-A shows **Available** status and **Accepting new sessions = Yes** in the Session hosts grid.

---

### Step 9 — Run test sessions

**Action:** Using two separate test accounts, open the AVD client and sign in to POOL-FIN-01. Both sessions should land on or be routable to SHFIN-01-A.

**Expected result:** Both test sessions remain connected and stable for at least 5 minutes with no disconnect. The desktop renders correctly.

---

## Verification

Run all verification checks after completing resolution. Do not close the incident until all checks pass.

1. **Portal — Host health**
   **Path:** Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts
   Confirm SHFIN-01-A shows **Available** and **Accepting new sessions = Yes**.

2. **Event log — No new DWM crash events**
   **Path:** SHFIN-01-A — Event Viewer > Windows Logs > Application
   Filter: Event ID `1000`, Source: `Application Error`, Logged: Last 30 minutes.
   Expected: No entries with `Faulting application name: dwm.exe` and `Faulting module name: igdumd64.dll`.

3. **Event log — No new DWM exit events**
   **Path:** SHFIN-01-A — Event Viewer > Windows Logs > Application
   Filter: Event ID `9009`, Source: `Desktop Window Manager`, Logged: Last 30 minutes.
   Expected: No new Event 9009 entries in the post-change window.

4. **Event log — DWM started successfully**
   **Path:** SHFIN-01-A — Event Viewer > Windows Logs > Application
   Filter: Event ID `9011`, Source: `Desktop Window Manager`.
   Expected: At least one Event 9011 entry confirming DWM started successfully after the restart.

5. **Event log — No rapid disconnect pattern**
   **Path:** SHFIN-01-A — Event Viewer > Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational
   Filter: Event IDs `21` and `40`.
   Expected: Test session Event 21 logon entries are present with no corresponding Event 40 disconnect within 10 seconds.

6. **Portal — Test session stability**
   **Path:** Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > User sessions
   Expected: Two test sessions on SHFIN-01-A are visible and have remained connected for 5+ minutes.

7. **User confirmation**
   Contact affected users and confirm they can log in and maintain a stable session. Monitor the incident ticket for 15 minutes for no new disconnect reports.

---

## Rollback

If any verification check fails, or if users continue disconnecting after the fix, immediately follow these steps.

### Step 1 — Drain SHFIN-01-A immediately

**Portal path:** Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > SHFIN-01-A

**Action:** Set **Allow new sessions** to **No**.

**Expected result:** SHFIN-01-A stops receiving new sessions within seconds. Users are rerouted to other healthy hosts.

---

### Step 2 — Mark host unavailable

**Portal path:** Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > SHFIN-01-A

**Action:** Set host status to **Unavailable** (or select **Disable host** if shown in your portal view).

**Expected result:** SHFIN-01-A is fully removed from user traffic. New sessions land only on SHFIN-02-A and any other available hosts in POOL-FIN-01.

---

### Step 3 — Confirm no sessions on SHFIN-01-A

**Portal path:** Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > User sessions

**Action:** Filter by host SHFIN-01-A and confirm the session list is empty.

**Expected result:** No active or disconnected sessions remain on the isolated host.

---

### Step 4 — Export incident evidence

**On SHFIN-01-A — Event Viewer > Windows Logs > Application:**
- Filter for Event IDs `1000` and `9009` covering the post-fix window.
- Right-click the filtered view > **Save Filtered Log File As** > save as .evtx with filename including host name and timestamp.

**Expected result:** Evidence file is saved locally and copied to a shared location for escalation.

---

### Step 5 — Escalate to image/endpoint engineering

**Action:** Raise an escalation ticket to the image or endpoint engineering team. Include:
- Host name: SHFIN-01-A
- Host pool: POOL-FIN-01
- The exported .evtx evidence file
- The driver version applied during the image update
- The timeline of the incident and fix attempt

**Expected result:** Engineering has actionable evidence to investigate the image pipeline fault. SHFIN-01-A remains isolated until engineering signs off on a safe state.

---

## Preventive

The following specific changes prevent recurrence. General advice such as "test before applying" is insufficient — these are the exact controls required.

### 1. Add graphics driver version check to pre-deployment image validation gate
**Owner:** Release Engineer | **Timing:** Before deployment (at image promotion decision)
**Control:** An automated check compares the candidate image Intel graphics driver version against the driver version baseline register (see Control 2 below). **Pass:** Image version matches baseline. **Fail:** Deployment is blocked and escalated to Change Manager for review and approval. **Automation:** Automated via Azure DevOps Pipeline or Packer validation step. [REQUIRES: image build pipeline with validation hooks]

### 2. Maintain driver version baseline register with change control gate
**Owner:** Image Owner | **Timing:** Immediately upon driver change approval and continuously
**Control:** A CMDB or spreadsheet entry records the approved Intel graphics driver version, date, and change ticket ID for each host pool (POOL-FIN-01, etc.). **Pass:** Entry is created/updated within 1 hour of change approval. **Fail:** Any image promotion without a corresponding baseline register entry is blocked by Control 1. Audit: quarterly review of baseline register against running hosts. **Automation:** Possible via API integration to CMDB; currently manual update required. [REQUIRES: CMDB access or designated spreadsheet with change control]

### 3. Deploy image updates to staging host with smoke test gate
**Owner:** Release Engineer | **Timing:** Before production deployment (mandatory pre-deployment test)
**Control:** All image updates must be applied to one non-production session host (e.g., SHFIN-STAGING-01) in a staging host pool first. Two service account logons must remain stable for 30 minutes each, with no Event 1000 (Application Error) or Event 9009 (DWM exit) in the Application log during the test window. **Pass:** Both test logons stable + zero Application Errors. **Fail:** Deployment blocked; escalate to Image Owner for investigation. **Automation:** Smoke test execution can be automated via PowerShell; event verification currently requires manual confirmation. [REQUIRES: staging host pool and automated logon capability]

### 4. Enable AVD Insights disconnect alerting with in-flight monitoring
**Owner:** Service Desk Lead | **Timing:** Configure before deployment; alert fires during rollout and after
**Control:** **Portal path:** Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Insights. Create alert rule: session disconnect rate per host exceeds 5 disconnects in 10 minutes. **Alert target:** on-call L2/L3 engineer. **Pass:** Alert fires within 2 minutes of threshold breach. **Fail:** Threshold breached with no alert; escalate to monitoring team. **Action on alert:** Immediately review host health via Detection Steps 1–3 and consider drain mode (Control 6 below). **Automation:** Automated alert delivery via email/PagerDuty.

### 5. Tag image update change tickets with driver version and host pools
**Owner:** Change Manager | **Timing:** When change ticket is created (before deployment)
**Control:** All change tickets for image updates must include: (a) host pools affected (e.g., POOL-FIN-01), (b) Intel graphics driver version deployed, (c) baseline register entry ID (from Control 2). **Pass:** All three fields populated before approval. **Fail:** Change ticket is returned to requester for completion. Verification: During incident triage, use driver version field for rapid correlation to recent changes. **Automation:** Mandatory fields in change ticket template; can be enforced via workflow rules in change management system.

### 6. Enable automatic drain and escalation on disconnect surge
**Owner:** Platform Engineer | **Timing:** During and immediately after deployment rollout
**Control:** When the disconnect alert (Control 4) fires, an automated runbook drains the affected host (set Allow new sessions to No) and creates a P2 ticket for on-call L2/L3. **Pass:** Host is drained within 3 minutes of alert firing; P2 ticket created. **Fail:** Runbook does not execute; manual drill training required for Service Desk. **Automation:** Azure Automation runbook or Logic App triggered by alert. [REQUIRES: Azure Automation and Logic App setup]

### 7. Post-deployment validation gate — confirm healthy state before change close
**Owner:** Service Desk Lead (post-deployment validation) | **Timing:** After deployment, before change ticket closure (minimum 30 minutes post-deployment)
**Control:** Before closing the change ticket, verify: (a) at least two test logons on each affected host pool remained stable for 10+ minutes, (b) Event 1000/9009 counts are zero in the post-deployment window, (c) no new disconnect-rate alerts fired in the last 15 minutes. **Pass:** All three checks pass; change can close. **Fail:** Any check fails; rollback is triggered (see Control 8 below). Verification command: `Invoke-Command -ComputerName SHFIN-01-A -ScriptBlock { Get-WinEvent -FilterHashtable @{LogName='Application';Id=1000,9009;StartTime=(Get-Date).AddMinutes(-30)} | Measure-Object }` — result should be zero events.

### 8. Automatic rollback trigger on post-deployment failure
**Owner:** Platform Engineer | **Timing:** Triggered during post-deployment validation (Control 7)
**Control:** If post-deployment validation (Control 7) fails for more than 5% of deployed hosts or if disconnect rate remains above 2 disconnects per 10 minutes 20 minutes after deployment, automatically roll back to the previous known-good image on affected hosts. **Pass:** Rollback initiates; users are rerouted during the rollback window. **Fail:** Rollback does not trigger; platform engineering is paged immediately. **Automation:** Automated via runbook comparing Event ID counts and disconnect metrics before/after deployment.

### 9. Update runbook and Known Error Record from incident learnings
**Owner:** L2/L3 Engineer (incident lead) | **Timing:** Within 24 hours of incident resolution
**Control:** After this incident resolves, update the DWM/igdumd64 Runbook and Known Error Record with: (a) any new detection signals or event IDs discovered, (b) new resolution steps that worked faster, (c) any timing or approval gates that slowed response. **Pass:** Changes merged into KB by EOD following incident close. **Fail:** Runbook not updated; findings from this incident are lost for the next occurrence. Verification: KB document version number increments and changelog is updated.

---

## Related Incidents and KB Articles

| Reference | Relationship |
|---|---|
| AVD Session Disconnects RCA — POOL-FIN-01 (07/2026) | Root cause analysis this article is derived from |
| AVD DWM/igdumd64 Disconnect Runbook v1.0 | Operational runbook for step-by-step execution during the incident |
| AVD Known Error Record — DWM igdumd64 Disconnect | Known error register entry for this fault pattern |
| AVD Hypothesis-Evidence Assessment — Session Disconnects | Diagnostic reasoning log used to confirm driver as root cause |
| KB: AVD Session Disconnects — End User Communication | User-facing communication templates for this incident type |
| KB: AVD Session Disconnects — L1 Triage (T-1003) | L1 triage ticket and initial symptom capture for related incident |

---

*This article should be reviewed and updated after any recurrence or change to the AVD image pipeline affecting graphics drivers.*
