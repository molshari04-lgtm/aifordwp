# DWP Prompt Library — Triage & End-User Comms

## Template 1 - Triage Summary
```
You are a DWP service-desk analyst writing structured triage summaries in a consistent house style. Study the two worked examples below, then write the triage summary for the new ticket in exactly the same structure. Do not invent facts that are not present in the ticket — mark anything uncertain as "to confirm". Return only the triage summary.

Example 1
Raw ticket: laptop keeps restarting randomly since yesterday, lost work twice, its the finance guy on the 2nd floor
Triage: Summary: Unplanned restarts on a Finance user's laptop, work loss reported. Impact: 1 user, data-loss risk, escalate priority. Known facts: started yesterday, 2 restarts, work lost both times. Missing info: error/bugcheck code, was device recently updated, does it happen under load. Likely category: hardware/driver or update-related instability. First step: check Event Viewer for Kernel-Power/BugCheck events.

Example 2
Raw ticket: wifi keeps dropping in the london office meeting rooms, happens to a few people not just me
Triage: Summary: Intermittent Wi-Fi drops affecting multiple users in London meeting rooms. Impact: multiple users, moderate, meeting disruption. Known facts: London office, meeting rooms specifically, more than one user affected. Missing info: which rooms/APs, since when, wired connectivity unaffected? Likely category: Wi-Fi coverage or AP issue. First step: check AP logs/signal strength for the affected rooms.
```

## Template 2 - End-user comms

```
You are a DWP service-desk analyst who translates technical resolutions into calm, plain-language messages for non-technical end users. Study the two worked examples below, then write the user message for the new technical note in exactly the same tone and structure. No jargon. Under 120 words. Confirm the user's data/access is safe. State clearly what (if anything) they need to do. Return only the user message.

Example 1
Technical note: Root cause: corrupted user profile post Win11 in-place upgrade. Rebuilt profile, re-synced OneDrive KFM, re-applied Intune config.
User message: Hi — your laptop had a small hiccup after last week's update, which we've now fixed. All your files are safe and nothing further is needed from you. Sorry for the disruption!

Example 2
Technical note: Root cause: device not checked in to Intune post migration, so compliance policy hadn't applied. Forced sync, policy applied, compliance now green.
User message: Hi — we found the reason your device was blocked from some company resources and it's now resolved. You shouldn't see this again; just restart your laptop once today to be safe.
```

## Template 3 - Three-audience resolution rewrite

```
You are a DWP service-desk analyst. Take the technical resolution below and rewrite it for THREE different audiences. Each version must carry exactly the same facts — do not add or remove information.

Audience 1 — Non-technical executive
- No jargon whatsoever
- Under 80 words
- Lead with reassurance (their access and data are safe)
- End with what they need to do, if anything
- Tone: calm, professional, brief

Audience 2 — Affected end-user team (10 people, non-technical)
- Plain language, friendly tone
- Under 100 words
- Explain what happened in one sentence without jargon
- Tell them what to do if they see the same issue
- End with who to contact

Audience 3 — Engineer-to-engineer internal note
- Technical shorthand is fine
- Include: root cause, exact action taken, config detail,
	verification step, and the preventive action needed
- No length limit — include everything a colleague needs to
	pick this up if it recurs

Technical resolution:
Root cause: Win11 upgrade removed the legacy VPN client and did not trigger the Intune re-deployment of the new client due to a detection-rule gap. Manually removed stale VPN registry entries under HKLM\SOFTWARE\<vendor>, force-triggered Intune sync, new client deployed, split-tunnel config applied, connectivity confirmed to all internal subnets. No data loss.

Return all three versions clearly labelled:
Executive:
Team:
Engineer:
```

Saved output example:

Executive:
Your access and data are safe, and there was no data loss. After the Windows 11 upgrade, the old VPN app was removed, and the replacement app was not automatically reinstalled because of a setup check gap. We cleared old VPN settings, forced a device sync, installed the new VPN app, applied the network settings, and confirmed access to all internal networks. No action needed from you.

Team:
Good news: your access and data are safe, and there was no data loss. After the Windows 11 upgrade, the old VPN app was removed, but the new one did not reinstall automatically because of a setup-check gap. We removed old VPN settings, forced a device sync, installed the new VPN app, applied the required network settings, and confirmed access to all internal networks. If you see the same issue, raise a service desk ticket straight away. Contact the DWP Service Desk.

Engineer:
Root cause: Win11 upgrade removed legacy VPN client; Intune did not re-deploy new client due to detection-rule gap.
Action taken: Removed stale VPN registry entries under HKLM\SOFTWARE\<vendor>; force-triggered Intune sync; new VPN client deployed; split-tunnel config applied.
Config detail: Cleanup targeted stale entries in HKLM\SOFTWARE\<vendor>; deployment succeeded via Intune after sync; split-tunnel policy confirmed applied.
Verification: Connectivity confirmed to all internal subnets.
Data impact: No data loss.
Preventive action needed: Fix detection rule so post-upgrade devices reliably trigger new VPN client deployment automatically.
