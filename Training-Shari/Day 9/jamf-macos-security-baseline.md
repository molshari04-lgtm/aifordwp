# macOS JAMF Configuration Profile – Security Baseline Translation

**Author:** DWP Engineer
**Date:** 2026-08-14
**Scope:** 25-device Design team macOS fleet, managed via Jamf Pro
**Delivery Mechanism:** Configuration Profiles scoped to a Smart Group targeting the Design team fleet
**Compliance Visibility:** Jamf Pro Smart Groups + Extension Attributes (Jamf has no native "grace period" compliance engine like Intune — compliance state is built from inventory criteria, covered in the Compliance Visibility section below)

---

## How This Document Is Organised

Each requirement below maps a security baseline control to the Jamf Pro configuration profile payload that enforces it. As with the Windows 11 Intune baseline from Day 6, Jamf periodically renames payload sections and individual setting labels between versions. Where the exact UI wording is uncertain, this is called out explicitly — **verify against your own Jamf Pro instance before enforcing**, do not trust an exact label from this response.

---

## Requirement 1 – FileVault Disk Encryption Must Be Enabled

| Field | Detail |
|---|---|
| **Payload Type** | Security & Privacy (FileVault payload — sits under Jamf Pro's dedicated **FileVault** configuration profile payload, separate from the general Restrictions payload) |
| **Value** | Enable FileVault: **On**; Recovery key type: **Institutional recovery key (or Individual/Personal key, escrowed to Jamf Pro)**; "Enable FileVault" deferral: allow up to a fixed number of login attempts (e.g., 1) before forcing enablement |
| **Supporting Settings** | Enable "Show Recovery Key" disabled to prevent the user reading/screenshotting the key; enable escrow so the Personal Recovery Key (PRK) is uploaded to Jamf Pro on encryption completion |
| **Effect** | Forces full-disk encryption (XTS-AES-128) on the boot volume so data at rest is unreadable if a laptop is lost or stolen. Jamf's FileVault payload also lets you defer the encryption prompt for a set number of user login attempts, then force it. |
| **False-Positive Risk** | A device can show as "FileVault not enabled" in Jamf inventory simply because the encryption process is still running in the background (can take hours on larger disks) or because the Jamf inventory update hasn't run since encryption completed. Devices where a user deferred the enablement prompt right up to the max deferral count will also flag until the next login. If the recovery key isn't escrowed correctly (e.g., FileVault was turned on manually by the user before Jamf could manage it), Jamf may report the device as non-compliant even though disk encryption is active — this shows as a "no escrowed key" state, not a "FileVault off" state, so check which condition triggered the flag before treating it as unencrypted. |
| **Recommendation** | Build a Smart Group on the criteria `FileVault 2 Status` is not `Encrypted` to isolate genuinely unencrypted devices from key-escrow-only failures (`FileVault 2 Partition Encryption State` reports the escrow state separately). Scope a Self Service policy or forced-enrollment notification to that Smart Group rather than assuming inventory lag is a real failure. Re-run `jamf recon` (inventory update) on a device before escalating a FileVault ticket. |

> ⚠️ **UI Change Flag:** In current Jamf Pro this is its own payload named simply **FileVault**, not nested under "Security & Privacy" as it may have been in older versions covered in training data. Confirm the payload name and the location of the "escrow recovery key" toggle in your Jamf Pro version before building the profile.

---

## Requirement 2 – Gatekeeper Must Be Enabled (Identified Developers Only)

| Field | Detail |
|---|---|
| **Payload Type** | Security & Privacy payload → **General** tab (Gatekeeper section) |
| **Value** | Allow apps downloaded from: **App Store and identified developers** (the "Anywhere" option should be disallowed/greyed out) |
| **Supporting Settings** | Consider pairing with a **Notarization** enforcement note for internal engineering — unsigned internal build tools will also be blocked unless notarized or explicitly allowlisted via a Privacy Preferences Policy Control (PPPC) profile |
| **Effect** | Blocks execution of unsigned or unnotarized applications, restricting installs to Mac App Store apps and apps signed with an Apple Developer ID that pass notarization. Reduces the risk of unvetted or malicious software running on Design team devices. |
| **False-Positive Risk** | Design teams commonly use industry tools (plugins, fonts, codecs, older creative-suite utilities) distributed outside the App Store without a valid Developer ID signature, or with a signature that has expired/been revoked. These will be blocked and reported by helpdesk as "app won't open" rather than as a security flag, so triage should check Gatekeeper status before assuming an app packaging issue. A profile that was pushed but not yet applied (pending profile install) can also show inconsistent Gatekeeper state in inventory during the sync window. |
| **Recommendation** | Maintain an allowlist process for known Design-team plugin vendors: request a signed/notarized build from the vendor first; if unavailable, use a scoped Jamf policy to pre-approve a specific binary via `spctl --add` rather than disabling Gatekeeper fleet-wide. Do not grant blanket "Anywhere" access to resolve isolated plugin issues. |

> ⚠️ **UI Change Flag:** Apple has changed Gatekeeper's user-facing options across macOS versions (older macOS exposed a distinct "Anywhere" radio button in System Preferences that newer macOS versions hide entirely, only reachable via `spctl` or MDM enforcement). Confirm which Gatekeeper enum values your Jamf Pro payload currently exposes and whether "Anywhere" is still selectable at the OS level on the fleet's macOS version — verify rather than assuming a training-era screenshot.

---

## Requirement 3 – Minimum macOS Version: Current Stable Minus One Point Release

| Field | Detail |
|---|---|
| **Payload Type** | Restrictions payload → **Applications** tab, "OS Restrictions" section (Jamf refers to this as **Minimum Operating System Version**); enforcement of an actual upgrade (rather than just flagging) is done via a separate **Managed Software Update** payload/policy in current Jamf Pro |
| **Value** | Set to the second-to-latest point release of the current macOS major version (e.g., if current stable is 15.6, set minimum to 15.5) — **do not hardcode a version number here without checking Apple's current release**, since it changes every point release |
| **Supporting Settings** | Pair with a **Managed Software Update** policy or Smart Group + Self Service "Update Now" workflow to actually remediate devices below the minimum, since the Restrictions payload alone only flags/blocks, it does not force the upgrade |
| **Effect** | Devices below the configured minimum are flagged in Jamf inventory as non-compliant with the OS version requirement, and Smart Groups built on this criterion can trigger an enforced-update policy or restrict access to resources. |
| **False-Positive Risk** | Devices that are pending a reboot to finalize an already-downloaded macOS update will still report the old build number until restarted, so they'll flag as non-compliant despite having done everything short of rebooting. Devices on a staggered/deferred update ring (common where Design team workstations delay updates to avoid breaking Adobe/Creative Cloud compatibility) will legitimately sit one point release behind by design — don't treat this as a security gap without checking the deferral schedule first. |
| **Recommendation** | Align the minimum version with the Design team's Adobe/Creative Cloud compatibility testing window — do not set the compliance minimum to the very latest point release on day 1 of an Apple release. Build a Smart Group on `Operating System Version` less than the target string, and scope a `softwareupdate` Self Service policy to it. Review and update this value at every Apple point release. |

> ⚠️ **UI Change Flag:** Confirm today's actual "current stable minus one" version number directly from Apple's macOS release notes before setting this value — training data cannot be relied upon for the current point release number, and this setting requires review at each new point release, not just at initial profile creation.

---

## Requirement 4 – Firewall Must Be Enabled

| Field | Detail |
|---|---|
| **Payload Type** | Security & Privacy payload → **Firewall** tab |
| **Value** | Enable Firewall: **On**; optionally enable "Block all incoming connections" only if the Design team doesn't rely on peer-to-peer tools (e.g., AirDrop, screen sharing, local network rendering tools), otherwise leave per-app rules to allow signed apps automatically |
| **Supporting Settings** | "Enable stealth mode" can be enabled to prevent the device responding to network probes, if it does not conflict with local network collaboration tools in use by the Design team |
| **Effect** | Enables the macOS Application Layer Firewall, blocking unsolicited inbound connections to the device except for explicitly allowed signed applications and services. |
| **False-Positive Risk** | Design workflows frequently depend on local network services — AirDrop, Adobe Creative Cloud device sync, local rendering/collaboration tools (e.g., Sidecar, screen sharing for client reviews) — which require inbound connections. If "Block all incoming connections" is enabled too aggressively, these will fail silently and get reported as app bugs, not firewall blocks. Also, Jamf's firewall payload state can lag actual System Settings state briefly after a profile push until the next inventory update. |
| **Recommendation** | Do not enable "Block all incoming connections" fleet-wide for the Design team without first surveying which collaboration tools rely on inbound LAN traffic. Test on a pilot subset of the 25 devices before scoping to the full Smart Group. |

> ⚠️ **UI Change Flag:** The Firewall payload in Jamf Pro has been fairly stable, but the underlying macOS System Settings location for firewall (moved out of "Security & Privacy" into a standalone "Network > Firewall" pane in recent macOS versions) has changed the on-device verification path. Verify where firewall status actually surfaces on the fleet's current macOS version so helpdesk can confirm state locally, not just via Jamf inventory.

---

## Requirement 5 – Login Password Required After Sleep/Screen Saver

| Field | Detail |
|---|---|
| **Payload Type** | Security & Privacy payload → **General** tab, "Require password after sleep or screen saver begins" setting (some Jamf versions surface this instead under a dedicated **Login Window** payload) |
| **Value** | Require password: **Immediately** (0 seconds grace period) |
| **Supporting Settings** | Pair with a **Screen Saver** payload enforcing a maximum idle timeout (e.g., 10 minutes) so the password requirement actually triggers within a reasonable window rather than relying on the user manually invoking sleep/screen saver |
| **Effect** | Forces the macOS login prompt to appear immediately when the display sleeps, the screen saver activates, or the lid is closed, preventing walk-up access to an unlocked, unattended device. |
| **False-Positive Risk** | Devices used with external displays/docks in a "clamshell mode" setup can behave inconsistently with sleep/wake triggers, occasionally showing as non-compliant when the internal display state doesn't match the external monitor's power state. Users who disable the screen saver entirely (rather than just changing its timeout) can cause this policy to appear unenforced even though the underlying password-after-sleep setting is still active, since the two settings are evaluated together in some inventory views — check which specific sub-setting triggered the flag. |
| **Recommendation** | Enforce the screen saver idle timeout via profile (not just relying on the password-after-sleep flag) so clamshell-mode Design workstations with external monitors still trigger the lock reliably. Verify the specific sub-setting driving any non-compliance report before treating it as a lock-screen failure. |

> ⚠️ **UI Change Flag:** This setting has moved between "Security & Privacy" and a standalone "Login Window" payload across different Jamf Pro releases. Confirm the current payload location in your instance before building the profile, and check whether your macOS version still honors a grace-period value other than "Immediately" (Apple has tightened this over time on managed devices).

---

## Requirement 6 – Automatic Security Updates Enabled

| Field | Detail |
|---|---|
| **Payload Type** | Restrictions payload → **Applications** tab / **Software Update** payload (Jamf Pro has a dedicated **Software Update** payload in newer versions, distinct from general Restrictions) |
| **Value** | Automatically check for updates: **On**; Automatically install macOS updates: **On**; Automatically install system data files and security updates: **On**; Install app updates from the App Store: **On** |
| **Supporting Settings** | On current macOS, "security responses" (rapid security response / XProtect definition updates) is a distinct sub-toggle from full OS updates — ensure both are enabled, not just the top-level switch |
| **Effect** | Ensures Apple's background security patches (XProtect definition updates, malware removal tool updates, and critical security patches) install automatically without requiring user interaction, closing the window of exposure for known vulnerabilities. |
| **False-Positive Risk** | This setting only governs automatic *background* security patches — it does not force full macOS version upgrades, so a device can show "automatic updates: on" and still be behind on major/point releases (that's covered separately by Requirement 3). Devices that are asleep or off during Apple's scheduled update check windows will legitimately lag until they're next online and idle, which can look like the policy isn't applying when it's simply a timing gap. Metered/limited connections (e.g., mobile hotspot tethering) can also cause macOS to defer background updates by design. |
| **Recommendation** | Do not conflate "automatic security updates: on" with "device is fully patched" when triaging — check Requirement 3's OS version criteria separately. For devices frequently asleep/offline (e.g., laptops taken home overnight), consider a scheduled Jamf policy to trigger update checks at next check-in rather than relying solely on Apple's background schedule. |

> ⚠️ **UI Change Flag:** Apple has split "automatic update" behavior into multiple discrete toggles (OS updates, security responses/XProtect, app updates) across recent macOS releases, and Jamf's payload structure for this has changed to match. Verify the exact sub-toggles available in your Jamf Pro version's Software Update payload — do not assume a single on/off switch covers everything described here.

---

## Step-by-Step: Creating the Profile in Jamf Pro

Use these steps to build and scope the configuration profile in one session.

### Step 1 – Open the Configuration Profiles area
1. Sign in to your Jamf Pro instance as an account with Configuration Profile permissions.
2. In the left navigation, select **Computers**.
3. Select **Configuration Profiles**.

### Step 2 – Create the profile
1. Click **+ New**.
2. On the **General** payload tab, set:

| Field | Value |
|---|---|
| Name | `DWP-macOS-Design-Security-Baseline` |
| Description | `Enforces DWP security baseline: FileVault, Gatekeeper, minimum OS version, Firewall, login password after sleep, automatic security updates.` |
| Level | `Computer Level` |
| Distribution Method | `Install Automatically` |

### Step 3 – Configure each payload

#### FileVault payload
| Setting | Value |
|---|---|
| Enable FileVault | On |
| Recovery Key Type | Institutional (or Personal, escrowed) |
| Escrow Location Description | Jamf Pro server |
| Enable Deferral | Allow up to 1 login attempt before forcing enablement |

#### Security & Privacy payload → General
| Setting | Value |
|---|---|
| Gatekeeper: Allow apps downloaded from | App Store and identified developers |
| Require password after sleep or screen saver begins | Immediately |

#### Security & Privacy payload → Firewall
| Setting | Value |
|---|---|
| Enable Firewall | On |
| Block all incoming connections | Off (pending pilot review) |
| Enable stealth mode | On (pending pilot review) |

#### Restrictions payload → Applications (OS Restrictions)
| Setting | Value |
|---|---|
| Minimum Operating System Version | Current stable minus one point release (verify before entering) |

#### Software Update payload
| Setting | Value |
|---|---|
| Automatically check for updates | On |
| Automatically install macOS updates | On |
| Automatically install system data files and security updates | On |
| Install app updates from the App Store | On |

### Step 4 – Scope
1. Select the **Scope** tab.
2. Under **Targets**, click **Add**.
3. Select the Smart Group (or Static Group) containing the 25-device Design team fleet, e.g. `Design-Team-macOS-Fleet`.
4. If any Design devices require an exception (e.g., a device under active vendor troubleshooting), add it to **Exclusions** rather than weakening the profile for the whole group.

### Step 5 – Save and confirm deployment
1. Click **Save**.
2. Confirm the profile shows **Scope: 25 computers** (or the expected count) on the Configuration Profiles list.
3. Force a check-in on a pilot device (`sudo jamf policy` or **Recon** button in Jamf Pro's device record) to confirm the profile installs before assuming full-fleet rollout succeeded.

---

## Compliance Visibility (Jamf's Equivalent of Intune's Grace Period / Compliance State)

Jamf Pro does not have a built-in "grace period" or a native compliant/non-compliant flag the way Intune compliance policies do. Compliance visibility instead has to be built from **Smart Groups** driven by **inventory criteria** and, where inventory doesn't natively expose a setting, an **Extension Attribute** (a custom script that reports a value back into inventory).

### Recommended Smart Group criteria per requirement

| Requirement | Smart Group Criteria |
|---|---|
| FileVault enabled | `FileVault 2 Status` is not `Encrypted` |
| Gatekeeper enabled | Extension Attribute running `spctl --status`, flagged if output is not `assessments enabled` |
| Minimum macOS version | `Operating System Version` less than target string |
| Firewall enabled | Extension Attribute running `defaults read /Library/Preferences/com.apple.alf globalstate`, flagged if `0` |
| Password after sleep | Extension Attribute checking the relevant `com.apple.screensaver` preference domain |
| Automatic security updates | Extension Attribute checking `softwareupdate --schedule` state |

### Building a "grace period" equivalent
Since Jamf has no native delay-before-flagging mechanism, replicate it by:
1. Scheduling the inventory update (`jamf recon`) policy to run at a regular check-in interval (e.g., every 24 hours).
2. Building the Smart Group on criteria that only match if the non-compliant state has persisted across the last **N** recorded inventory submissions, if your Jamf version's advanced search supports date-based criteria, or
3. Using a Smart Group notification (webhook or Slack/email integration) with a manual N-day follow-up process before escalating to a stricter action such as blocking Self Service access to line-of-business apps.

> There is no equivalent of Intune's Conditional Access block at the identity layer purely from Jamf. If the same enforce-at-access-time control is required, it must be paired with an identity provider's device-trust/compliance signal (e.g., a Jamf Connect + IdP integration) — Jamf configuration profiles alone only configure and report settings, they do not gate cloud resource access on their own.

---

## Settings Flagged for UI Verification

The following settings should be verified in your live Jamf Pro instance before profile creation, as payload names or labels may have changed since training data:

| Setting | Reason to Verify |
|---|---|
| FileVault payload location | May sit under a standalone FileVault payload rather than "Security & Privacy" depending on Jamf Pro version |
| Gatekeeper "Anywhere" option | Apple has removed/hidden this option in System Settings on newer macOS versions; confirm what Jamf's payload enum still exposes |
| Minimum Operating System Version | Requires the current Apple stable/point-release number, which must be checked at time of deployment, not assumed from training data |
| Login password after sleep | May be under "Security & Privacy" or a separate "Login Window" payload depending on Jamf Pro release |
| Software Update payload sub-toggles | Apple has split automatic update behavior into multiple discrete toggles across recent macOS releases; Jamf's payload structure follows suit |

---

## Post-Assignment Validation Steps

### 1 – Where to Find a Device's Compliance Status for This Specific Profile

**Path — device-centric view (recommended for a single test device):**

1. Go to **Computers > Search Inventory**.
2. Search for the device by name or serial number and open its inventory record.
3. Select the **Management** tab, then **Configuration Profiles**.
4. Confirm `DWP-macOS-Design-Security-Baseline` is listed as **Installed**.
5. Select the **Applications** or **Extension Attributes** tab (depending on Jamf version) to review the reported values for FileVault status, Gatekeeper state, and OS version against the baseline.

**Path — group-centric view (recommended when checking across the fleet):**

1. Go to **Computers > Smart Groups**.
2. Open the Smart Group tracking non-compliant devices, e.g. `Design-macOS-FileVault-NonCompliant`.
3. Review the member list — this is the live set of devices currently failing that criterion.
4. Cross-reference against `Configuration Profiles > DWP-macOS-Design-Security-Baseline > Scope` to confirm the profile is actually assigned to every device in the Smart Group.

> **Tip:** After a profile push or a settings change on the device, allow time for the next check-in cycle (default check-in frequency, or trigger `sudo jamf recon` manually) before treating inventory as current. If inventory still looks stale, confirm the device has network connectivity to the Jamf Pro server and that the `jamf` binary's check-in launch daemon is running.

---

### 2 – Compliance State Definitions (Jamf Equivalent) and Access Impact

| State | What It Means | Access Impact |
|---|---|---|
| **Profile installed, all criteria pass** | The device has the configuration profile installed and inventory/Extension Attribute values match the required baseline state. | No native access block from Jamf alone. If paired with an identity provider device-trust signal, access is granted. |
| **Profile installed, one or more criteria fail** | The profile is on the device (e.g., Firewall payload applied) but the reported state doesn't match (e.g., FileVault still shows unencrypted, or Gatekeeper shows disabled). | No automatic block unless a separate enforcement layer (Self Service restriction, IdP device-trust policy) is configured to act on the Smart Group membership. This is the key structural difference from Intune — Jamf reports state, it does not gate access on its own. |
| **Profile not yet installed / pending** | The device is in scope but has not checked in since the profile was scoped, or the push failed (e.g., device offline, MDM channel issue). | Same as above — no block, but the setting itself is genuinely not yet enforced on the device. Trigger a manual check-in or investigate MDM communication before assuming the setting is being ignored. |
| **Excluded** | The device is in an exclusion group (e.g., a documented vendor-testing exception). | Deliberately out of scope — should be tracked separately and reviewed periodically so exceptions don't become permanent by default. |

> **Key operational point:** Unlike Intune's grace-period-then-block model, a Jamf configuration profile with a failing criterion produces no automatic consequence by itself. Any "block until remediated" behavior must be deliberately built — either through a paired identity/access control integration, or through a manual/scripted process (e.g., a Self Service restriction policy, or disabling network access via a captive-portal-style remediation workflow). Do not assume Jamf inventory failure equals blocked access; verify what enforcement layer, if any, actually consumes that signal in your environment.

---

### 3 – FileVault False Positive: Three Most Common Causes and Fastest Checks

**Scenario:** Device shows non-compliant on "FileVault enabled" in Jamf inventory, but FileVault appears to be running.

---

#### Cause 1 – Encryption Is Still In Progress

FileVault encryption on a large disk (or one with substantial existing data) can take hours to complete in the background. During this window, the volume is only partially encrypted and Jamf may report an in-progress or unencrypted state depending on the exact inventory field checked.

**Fastest check — run on the device locally or via a Jamf Self Service script:**

```bash
fdesetup status
```

| Output | Meaning |
|---|---|
| `FileVault is On.` | Fully encrypted — Jamf should report compliant on next inventory update |
| `Encryption in progress: X% complete` | Still encrypting — not yet a real failure |
| `FileVault is Off.` | Genuinely disabled — the false positive cause is ruled out, this is a real gap |

**Fix:** No action needed if encrypting — allow it to complete, then force `sudo jamf recon` to refresh inventory once `fdesetup status` returns `On`.

---

#### Cause 2 – Inventory Report Has Not Yet Refreshed After Encryption Completed

FileVault may have finished encrypting after the device's last Jamf check-in. Jamf is reporting a stale state — the device *was* unencrypted when last inventoried, but is now compliant. The console has not caught up.

**Fastest check:**

1. On the device: confirm `fdesetup status` returns `FileVault is On.`
2. In Jamf Pro: check the **Last Inventory Update** timestamp on the device's inventory record.
3. If encryption completed *after* that timestamp, this is a stale report.

**Fix:** Trigger a manual inventory update: `sudo jamf recon`, or push a Jamf Pro **Update Inventory** command from the device's management commands menu. Re-check the Smart Group membership after the next check-in completes.

---

#### Cause 3 – FileVault Is On But the Recovery Key Was Never Escrowed to Jamf

FileVault may have been enabled by the user directly (via System Settings) before the Jamf configuration profile applied, or the escrow step failed silently (e.g., due to a certificate issue on the Jamf Pro server, or the user dismissing the key-generation prompt). Encryption is active, but Jamf has no record of the recovery key, and some inventory criteria treat "no escrowed key" as equivalent to non-compliant.

**Fastest check — run on the device:**

```bash
fdesetup status
sudo fdesetup list
```

If `fdesetup status` shows `On` but the device's Jamf Pro inventory record shows no recovery key under **Management > FileVault Recovery Key**, escrow failed or never occurred.

**Fix options:**
1. Issue a **Personal Recovery Key rotation** command from Jamf Pro (`Management Commands > Rotate FileVault Key`, if supported by the enrolled macOS version) to force a fresh key generation and escrow.
2. If rotation isn't available, disable and re-enable FileVault via a scoped Self Service policy so the configuration profile re-triggers the escrow flow.
3. Confirm the Jamf Pro server's FileVault escrow certificate is valid and not expired — an expired escrow certificate silently breaks new key uploads fleet-wide, not just for one device.

---

#### FileVault False Positive — Quick Reference

| Cause | On-Device Check | Fix |
|---|---|---|
| Encryption still in progress | `fdesetup status` shows `Encryption in progress` | Wait for completion, then `sudo jamf recon` |
| Stale inventory report | Last inventory timestamp predates encryption completion | Force `sudo jamf recon` or push Update Inventory command; wait for re-evaluation |
| Recovery key not escrowed | `fdesetup status` is `On` but no key shown in Jamf Pro record | Rotate FileVault key via Jamf, or verify/renew the escrow certificate |

---

## Summary Table

| # | Requirement | Payload Type | Value | Enforcement Layer |
|---|---|---|---|---|
| 1 | FileVault encryption | FileVault | On, key escrowed to Jamf | Smart Group + FileVault Recovery Key check |
| 2 | Gatekeeper | Security & Privacy → General | App Store + identified developers | Extension Attribute (`spctl --status`) |
| 3 | Minimum macOS version | Restrictions → Applications (OS Restrictions) | Current stable minus one point release (verify exact number) | Smart Group on `Operating System Version` |
| 4 | Firewall | Security & Privacy → Firewall | On | Extension Attribute (`com.apple.alf globalstate`) |
| 5 | Password after sleep/screen saver | Security & Privacy → General (or Login Window) | Immediately | Extension Attribute (`com.apple.screensaver` domain) |
| 6 | Automatic security updates | Software Update payload | On (all sub-toggles) | Extension Attribute (`softwareupdate --schedule`) |

---

## General Verification Discipline

Same discipline as the Intune labs on Day 6: Jamf Pro payload names, tab locations, and available enum values change between releases, and macOS itself periodically relocates the on-device settings that these payloads control. Before rolling this profile out to the 25-device Design fleet:

1. Confirm each payload name and field location against the live Jamf Pro instance, not this document.
2. Confirm current macOS stable and stable-minus-one version numbers directly from Apple's release notes at the time of deployment.
3. Re-review this baseline at each macOS point release and each Jamf Pro upgrade, since both sides of the mapping can shift independently.

---

## References

- Jamf Pro configuration profiles documentation: `https://learn.jamf.com/en-US/bundle/jamf-pro-documentation-current/page/Configuration_Profiles.html`
- FileVault payload and escrow: `https://learn.jamf.com/en-US/bundle/jamf-pro-documentation-current/page/FileVault_2.html`
- Smart Groups and Extension Attributes: `https://learn.jamf.com/en-US/bundle/jamf-pro-documentation-current/page/Smart_Groups.html`
- Apple Gatekeeper documentation (verify current enum values): `https://support.apple.com/guide/security/gatekeeper-and-runtime-protection-sec5599b66df/web`
- Apple macOS release notes (verify current stable/point release before setting Requirement 3): `https://support.apple.com/en-us/100100`
