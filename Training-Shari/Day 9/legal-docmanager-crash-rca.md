# Root Cause Analysis: Legal Floor 6 App Crash Wave (DocManager.exe)

**RCA date:** 2026-08-14
**Service:** Legal Document Manager (`DocManager.exe`) on Floor 6
**Affected device group:** `Legal-Win11` (45 devices)
**Status:** Evidence-based root cause identified; resolution must be confirmed by the verification checks below

## 1. Executive summary

All 45 devices in the `Legal-Win11` collection on Floor 6 experienced a sharp health decline starting around 09:44–10:00 on 2024-03-25. DEX Score fell from a healthy 90–91 to 55–58, App crash rate rose from 0.1–0.2% to 6.2–6.8%, and Disk I/O moved from Normal to High. `DocManager.exe` accounted for 74% of all crashes in the 10:00–11:00 window.

SCCM shows that `Legal Document Manager v2.1` was deployed to this exact 45-device collection between 09:38:20 and 09:44:07, reported as a clean success with 0 failures. Vendor release notes for v2.1 disclose a known limitation: the new auto-save feature builds a background index on first run, and on devices with under 8GB RAM this indexing can cause high disk I/O and intermittent crashes for the first few hours post-install. 18 of the 45 devices (40%) have 4GB RAM, below the vendor's stated safe threshold.

The immediate technical cause is the v2.1 auto-save indexing process consuming disk I/O and destabilizing `DocManager.exe`, concentrated on the sub-8GB-RAM devices. SCCM's "0 failures" result reflects installer success only — it does not, and cannot, capture this post-install application behavior.

## 2. Impact and scope

| Item | Observed state |
|---|---|
| Affected device group | `Legal-Win11`, Floor 6, 45 devices |
| Triggering change | `Legal Document Manager v2.1` deployment, 09:38:20–09:44:07, 45 of 45 devices, 0 install failures |
| Pre-incident baseline | DEX Score 90–91, crash rate 0.1–0.2%, Disk I/O Normal (08:00–09:00) |
| Post-incident state (last sample) | DEX Score 55, crash rate 6.8%, Disk I/O High (10:00–11:00) |
| Dominant failing process | `DocManager.exe`, 74% of crashes in the 10:00–11:00 window |
| At-risk hardware tier | 18 of 45 devices (40%) with 4GB RAM — below vendor's 8GB minimum for the new auto-save indexing feature |
| Lower-risk hardware tier | 27 of 45 devices (60%) with 8GB RAM — meets vendor's stated minimum |

The incident is application- and change-specific rather than a general fleet health event: no other application shows an elevated crash share, and no other change is recorded in the same window in the supplied data.

## 3. Supporting evidence

### Nexthink DEX evidence

- 08:00: DEX Score 91, crash rate 0.1%, Disk I/O Normal.
- 09:00: DEX Score 90, crash rate 0.2%, Disk I/O Normal — stable baseline through this point.
- 10:00: DEX Score 58, crash rate 6.2%, Disk I/O High — sharp degradation.
- 11:00: DEX Score 55, crash rate 6.8%, Disk I/O High — degradation sustained, not a single-sample anomaly.
- Top crashing process, 10:00–11:00: `DocManager.exe`, 74% of all crashes in that window.

### SCCM deployment evidence

- 09:38:20: Deployment of `Legal Document Manager v2.1` started to collection `Legal-Win11` (45 devices).
- 09:44:07: Install completed, 45 of 45 devices, reported as Success with 0 failures.
- Previous version, v2.0, had been deployed and stable for 6 weeks prior to this change.
- Vendor release notes: v2.1 adds an auto-save feature; known limitation states that on devices with under 8GB RAM, the auto-save indexing process can cause high disk I/O and intermittent crashes during the first few hours after installation while the initial index builds.
- Fleet hardware split: 60% (27 devices) at 8GB RAM, 40% (18 devices) at 4GB RAM.

### Data-source limitation

Neither source alone establishes the full picture: SCCM's success status does not capture post-install application health, and DEX has no visibility into what change was deployed. The root cause below depends on reading the two sources together against a shared timeline.

## 4. Timeline

| Time | Event |
|---|---|
| 08:00 | DEX Score 91, crash rate 0.1%, Disk I/O Normal |
| 09:00 | DEX Score 90, crash rate 0.2%, Disk I/O Normal |
| 09:38:20 | SCCM begins deploying `Legal Document Manager v2.1` to `Legal-Win11` (45 devices) |
| 09:44:07 | SCCM reports install complete: 45 of 45 devices, Success, 0 failures |
| ~09:44–10:00 | Auto-save indexing begins running on all 45 devices per vendor design; degradation onset window |
| 10:00 | DEX Score 58, crash rate 6.2%, Disk I/O High |
| 11:00 | DEX Score 55, crash rate 6.8%, Disk I/O High; `DocManager.exe` is 74% of crashes in this hour |

## 5. Causal analysis

### Confirmed immediate trigger

`Legal Document Manager v2.1` was deployed to all 45 `Legal-Win11` devices, completing at 09:44:07. The DEX degradation begins in the sample window immediately following this completion and is fully established by 10:00 — a timing gap consistent with the vendor's own description of index-building starting right after install.

### Probable underlying mechanism

The vendor-documented auto-save indexing defect, scoped explicitly to devices under 8GB RAM, is the most likely mechanism: it names the exact symptom pair observed (high disk I/O, intermittent crashes) and the exact onset window (first few hours post-install). 18 of 45 devices (40%) fall into that hardware band. The supplied data does not include a per-device crash breakdown by RAM tier, so this remains the leading hypothesis pending the check in Section 9, not yet a fully confirmed per-device fact.

### Contributing control gap

SCCM's deployment validation only checks installer exit status, not post-install application health or vendor-documented hardware compatibility. This allowed a release with a known, vendor-disclosed hardware limitation to reach 100% of a mixed-hardware collection in a single wave, including the 40% of devices explicitly outside the vendor's supported RAM range.

## 6. Five Whys

1. **Why are Legal Floor 6 users experiencing app crashes?**
   `DocManager.exe` is crashing intermittently, accounting for 74% of all crashes recorded on the fleet in the 10:00–11:00 window.

2. **Why is `DocManager.exe` crashing now, when it was stable for the prior 6 weeks on v2.0?**
   `Legal Document Manager v2.1` was deployed to the entire 45-device collection at 09:38–09:44, immediately before the crash rate and Disk I/O both spiked.

3. **Why would the v2.1 upgrade itself cause crashes when SCCM reported 0 install failures?**
   SCCM's success result only confirms the installer completed; it does not evaluate the application's runtime behavior after install completes.

4. **Why does v2.1 destabilize the application post-install?**
   The vendor's own release notes disclose that v2.1's new auto-save feature builds a background index on first run, which can cause high disk I/O and intermittent crashes for the first few hours after installation.

5. **Why does this affect a large share of the fleet rather than being an isolated issue?**
   The vendor scopes the limitation to devices with under 8GB RAM, and 18 of the 45 devices (40%) fall into that band — a large enough sub-population to plausibly account for the fleet-wide 6–7% crash rate observed. The exact per-device concentration by RAM tier is not yet directly confirmed and requires the check in Section 9.

## 7. Root cause statement

The Legal Floor 6 crash wave was caused by the `Legal Document Manager v2.1` deployment completed at 09:44:07 on all 45 `Legal-Win11` devices. The release's new auto-save feature triggers a background indexing process that the vendor documents as causing high disk I/O and intermittent crashes for the first few hours after install on devices with under 8GB RAM — a condition met by 18 of the 45 devices (40%). This mechanism is consistent with the observed timing (degradation onset immediately following install completion), the observed symptom (Disk I/O High alongside the crash spike), and the observed process concentration (`DocManager.exe` at 74% of crashes).

This is recorded as the confirmed root cause based on timing, process, and vendor-documentation alignment. The precise per-device crash distribution by RAM tier remains to be confirmed per Section 9 before problem closure.

## 8. Corrective action and order of operations

1. Preserve the SCCM deployment log, Nexthink DEX export, and hardware inventory for the `Legal-Win11` collection as incident evidence.
2. Pause further rollout of `Legal Document Manager v2.1` to any other collection until the indexing behavior is confirmed to resolve or a hardware-aware deployment plan is defined.
3. Notify Floor 6 Legal users of a known, temporary performance issue tied to a recent application update, to reduce duplicate helpdesk tickets.
4. Pull per-device crash counts for the 10:00–11:00 window and cross-reference against the hardware inventory to confirm the 4GB-RAM concentration.
5. On a sample of 4GB-RAM devices, check whether the `DocManager.exe` index build has completed and whether Disk I/O and crash rate recover without further action.
6. If the vendor provides a supported option to defer, throttle, or reschedule initial indexing (e.g., to an off-hours window), apply it to the remaining at-risk 4GB devices.
7. If crashes do not self-resolve within the vendor's stated "first few hours" window, roll back `Legal Document Manager` to v2.0 on the 4GB-RAM subset only, since v2.0 was stable for 6 weeks prior. Leave v2.1 in place on the 8GB-RAM subset, which meets the vendor's stated minimum.
8. Continue DEX monitoring on `Legal-Win11` past the observed window to confirm DEX Score, crash rate, and Disk I/O return to the pre-incident baseline (DEX Score ~90+, crash rate ~0.1–0.2%, Disk I/O Normal).

Do not roll back v2.1 fleet-wide if the 8GB-RAM subset remains healthy and meets the vendor's documented minimum — a targeted rollback avoids losing the auto-save feature for devices unaffected by the defect.

## 9. Verification and closure criteria

- Per-device crash data confirms crash concentration on the 4GB-RAM tier (or provides a corrected explanation if it does not).
- Affected 4GB-RAM devices show completed indexing and a return to Disk I/O Normal without further crashes.
- Fleet-wide DEX Score returns to the pre-incident baseline (~90+) and crash rate returns to ~0.1–0.2%.
- No further `DocManager.exe` crash spike is observed in the following observation period.
- If a targeted rollback was performed, the 4GB-RAM subset is confirmed running v2.0 and stable; the 8GB-RAM subset remains on v2.1 and stable.

## 10. Preventive and follow-up actions

| Priority | Action | Success measure |
|---|---|---|
| Immediate | Require review of vendor release notes for hardware-dependent known limitations before approving a fleet-wide deployment | No future deployment proceeds fleet-wide without an explicit hardware-compatibility check against the target collection |
| Immediate | Add a minimum-RAM (or other hardware) filter to SCCM collection criteria for releases with a vendor-documented hardware dependency | At-risk devices are excluded or staged separately, not included in the initial wave |
| Short term | Add post-deployment DEX/health monitoring as a required deployment validation step, not just installer exit status | A deployment is not marked "safe" until a post-install health check window has passed cleanly |
| Short term | Establish a staged/canary rollout process (e.g., deploy to a hardware-representative pilot subset first) for application updates with new resource-intensive features | Pilot subset health is confirmed before wider rollout |
| Problem management | Document this incident as a known pattern: SCCM install success does not validate post-install application health | Referenced in future RCAs involving application deployments with delayed onset symptoms |
