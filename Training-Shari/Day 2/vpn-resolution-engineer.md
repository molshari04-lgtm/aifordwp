Root cause: Win11 upgrade removed legacy VPN client; Intune did not re-deploy new client due to detection-rule gap.
Action taken: Removed stale VPN registry entries under HKLM\SOFTWARE\<vendor>; force-triggered Intune sync; new VPN client deployed; split-tunnel config applied.
Config detail: Cleanup targeted stale entries in HKLM\SOFTWARE\<vendor>; deployment succeeded via Intune after sync; split-tunnel policy confirmed applied.
Verification: Connectivity confirmed to all internal subnets.
Data impact: No data loss.
Preventive action needed: Fix detection rule so post-upgrade devices reliably trigger new VPN client deployment automatically.
