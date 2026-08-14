# Legal Floor 6 App Crash Wave Analysis

**Analysis date:** 2026-08-14
**Affected device group:** `Legal-Win11`, Floor 6, 45 devices
**Affected process:** `DocManager.exe`
**Comparison baseline:** Same fleet, 08:00–09:00 window, prior to the deployment

## 1. Scope and observed state

- `Legal-Win11` (45 devices) held a healthy baseline through 09:00: DEX Score 90–91, App crash rate 0.1–0.2%, Disk I/O Normal.
- Between 09:00 and 10:00, DEX Score fell from 90 to 58, App crash rate rose from 0.2% to 6.2%, and Disk I/O moved to High.
- The 10:00–11:00 sample confirms the degraded state is sustained, not a single-sample blip: DEX Score 55, crash rate 6.8%, Disk I/O still High.
- `DocManager.exe` accounts for 74% of all crashes recorded in the 10:00–11:00 window — the failure is concentrated in one application, not spread across the fleet's process mix.
- SCCM shows `Legal Document Manager v2.1` was deployed to the same 45-device collection, starting 09:38:20 and completing 09:44:07, reported as Success with 0 failures.
- The previous version, v2.0, had run stably on this fleet for 6 weeks, ruling out v2.0 as a pre-existing cause.
- Vendor release notes for v2.1 disclose a known limitation: a new auto-save indexing process that can cause high disk I/O and intermittent crashes for the first few hours after install, specifically on devices with under 8GB RAM.
- Fleet hardware: 60% of devices (27) have 8GB RAM; 40% (18) have 4GB RAM — below the vendor's stated safe threshold.

## 2. Data-source handling

Nexthink DEX and SCCM each cover only part of the picture. DEX shows *when* the fleet degraded and *which process* is failing, but has no visibility into deployments or configuration changes. SCCM shows *what changed* and *which devices are hardware-eligible for the vendor's known limitation*, but has no visibility into post-install device health or crash behavior. Neither source is treated as sufficient on its own in the ranking below; the deployment completion timestamp and the DEX degradation timestamps are read together throughout.

## 3. Ranked likely causes

### 1. v2.1 auto-save indexing on sub-8GB-RAM devices (vendor-documented limitation)

**Why it fits the evidence**

- The DEX degradation begins immediately after the v2.1 install completes (09:44) and is fully established by the 10:00 sample — a 15–20 minute gap consistent with an indexing process starting right after install and ramping up disk I/O.
- The dominant crashing process, `DocManager.exe`, is exactly the application just upgraded — not an unrelated process, which would point to a general fleet health issue instead.
- The vendor explicitly documents this exact symptom set (high disk I/O, intermittent crashes, first few hours post-install) and explicitly scopes it to devices under 8GB RAM.
- 40% of the fleet (18 devices) sits in that at-risk hardware band, which is a plausible source population for a 6–7% aggregate crash rate.

**Fastest confirming or eliminating check**

Pull per-device crash counts for the 10:00–11:00 window and cross-reference against the hardware inventory (4GB vs 8GB RAM). On a sample of affected 4GB devices, check whether the `DocManager.exe` index build has completed and whether Disk I/O/crash rate drop once it finishes without intervention. The hypothesis is confirmed if crashes concentrate on the 4GB tier and resolve as indexing completes; it is weakened if crashes are evenly distributed regardless of RAM or persist well beyond the vendor's stated window.

**Specific remediation if confirmed**

Pause further v2.1 rollout to other collections until the indexing behavior is confirmed to resolve or a hardware-aware deployment plan exists. Evaluate a vendor-supported option to defer/throttle initial indexing on 4GB devices, or schedule an off-hours re-index. If crashes do not self-resolve within the vendor's stated window, roll back v2.1 to v2.0 on the 4GB-RAM subset only, leaving v2.1 in place on the 8GB-RAM subset where the vendor's minimum is met.

### 2. Coincidental, unrelated fleet-wide health event

**Why it fits the evidence**

- A DEX Score collapse and crash-rate spike could in principle stem from an unrelated cause (e.g., a separate patch, storage subsystem issue, or network problem) that happened to land in the same hour as the v2.1 deployment.
- This ranks well below cause 1 because it requires an unexplained coincidence: the crash concentration in exactly the just-deployed process, and the timing gap matching the vendor's own documented onset window, are both left unexplained if this were the true cause.

**Fastest confirming or eliminating check**

Review SCCM and patch management logs for any other change (Windows update, driver, storage agent) deployed to `Legal-Win11` in the same window. Check whether crash processes other than `DocManager.exe` also rose materially in the 10:00–11:00 window. Absence of any other change, and crash concentration remaining in `DocManager.exe`, eliminates this cause.

**Specific remediation if confirmed**

If a separate concurrent change is found, treat it as its own incident and re-run this correlation against that change's timeline instead. No action needed against the v2.1 deployment if this cause is confirmed instead of cause 1.

### 3. Deployment-time corruption or partial install despite "0 failures" status

**Why it fits the evidence**

- SCCM's "Success, 0 failures" result only confirms the installer executed and exited cleanly on all 45 devices — it does not validate the resulting application state or file integrity.
- This ranks lowest because it does not explain the specific 8GB/4GB hardware pattern implied by the vendor note, and a corrupted install would be expected to produce failures unrelated to a RAM threshold, and likely with a different crash signature than "high disk I/O."

**Fastest confirming or eliminating check**

Compare `DocManager.exe` file versions/hashes across a sample of 8GB and 4GB devices to confirm the same v2.1 build landed correctly on both tiers. If file state is identical across tiers and crashes are still concentrated on the 4GB tier, this cause is eliminated in favor of cause 1.

**Specific remediation if confirmed**

Re-push the v2.1 package to any devices found with a corrupted or partial install; this would be a packaging/distribution fix rather than a hardware-driven rollback.

## 4. Finalized working hypothesis

The crash wave is caused by the `Legal Document Manager v2.1` auto-save indexing process, which the vendor documents as producing high disk I/O and intermittent crashes for the first few hours after install on devices with under 8GB RAM. The deployment completed at 09:44, and DEX shows the fleet-wide degradation fully established by 10:00, with `DocManager.exe` accounting for 74% of crashes in the following hour. 18 of 45 devices (40%) fall into the vendor's at-risk hardware band.

The exact per-device crash concentration by RAM tier is not directly confirmed by the supplied DEX and SCCM data and requires the check in Section 3, cause 1, before this is treated as fully proven rather than a leading hypothesis.
