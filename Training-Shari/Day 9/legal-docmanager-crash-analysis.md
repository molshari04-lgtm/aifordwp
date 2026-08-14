# Legal-Win11 DocManager Crash Wave: Ranked Analysis

**Date:** 2026-08-14
**Scope:** `Legal-Win11` (45 devices), primarily `DocManager.exe`

## Timing Weight

The Document Manager v2.1 deployment completed successfully across all 45 devices this morning. Both the crash wave and DEX-score degradation began shortly afterward; v2.0 had been stable for six weeks. This close sequence makes v2.1-related causes substantially more likely than unrelated causes, but correlation alone does not prove causation. All findings remain **to confirm**.

## Ranked Likely Causes

### 1. v2.1's documented post-install indexing limitation on 4GB devices - To confirm

**Why this fits the scope facts:** The vendor explicitly identifies high disk I/O and intermittent crashes during the first few hours after installation on lower-RAM devices while indexing completes. The incident begins shortly after the v2.1 deployment and has the same combination of `DocManager.exe` crashes, higher disk I/O, and degraded DEX score. Some of the 45 devices have 4GB RAM, placing them in the vendor-identified risk group.

**Fastest check:** Compare `DocManager.exe` crash counts and disk I/O for 4GB versus 8GB devices since deployment. A concentration on 4GB devices supports this cause; a similar pattern across both RAM tiers weakens it.

### 2. A broader v2.1 regression affecting all device configurations - To confirm

**Why this fits the scope facts:** The application version is the only stated change and the failures began shortly after it was deployed. A defect in v2.1 could affect `DocManager.exe` on both 4GB and 8GB devices, with high disk I/O and DEX degradation occurring as secondary effects. This ranks below the vendor-documented limitation because the scope facts do not identify a v2.1 issue outside the lower-RAM scenario.

**Fastest check:** Compare the `DocManager.exe` crash signature and crash rate between 4GB and 8GB devices. Material failures on 8GB devices as well as 4GB devices support a general v2.1 regression.

### 3. v2.1 indexing workload exhausting available resources on 4GB devices - To confirm

**Why this fits the scope facts:** Even if the documented issue is not the direct crash mechanism, an intensive first-hours indexing process can raise disk I/O and reduce headroom on devices with only 4GB RAM. That resource pressure could degrade DEX and make `DocManager.exe` unstable soon after deployment. This is closely related to cause 1 but remains distinct until the direct crash mechanism is known.

**Fastest check:** On affected 4GB devices, review concurrent memory pressure and disk I/O during `DocManager.exe` crashes. Resource saturation coinciding with crashes supports this cause.

### 4. A successful but faulty v2.1 installation state on a subset of devices - To confirm

**Why this fits the scope facts:** Zero install failures confirms deployment completion, not that every installed application state is usable. A subset with an incomplete or damaged installation could cause `DocManager.exe` crashes after the rollout. It ranks lower because this explanation does not inherently account for the vendor's lower-RAM limitation or the observed disk-I/O increase.

**Fastest check:** Compare the installed v2.1 application version and integrity on crashing devices against a non-crashing device in the same group. A discrepancy supports this cause.

### 5. An unrelated coincident device or environment issue - To confirm

**Why this fits the scope facts:** A separate change or device-level condition could have started mid-morning and produced crashes, disk I/O, and lower DEX scores independently of v2.1. It ranks last because the immediate timing after the deployment, the affected application's identity, v2.0's stable six-week baseline, and the matching vendor note all favor a v2.1-related explanation.

**Fastest check:** Review changes and incident signals for `Legal-Win11` during the same mid-morning window, then check whether similar disk-I/O or crash symptoms appear in devices that did not receive v2.1. Evidence of a separate concurrent issue supports this cause.