# Title: Finance Team Cannot Access Shared Drives (Win11)
# Version: 1.0
# Date: 07/08/2026
# Author: Sathishbabu
# Reviewed: self
# Status: draft
# Change: initial version from RCA

## 1) Prerequisites
- [ ] DHCP admin access for Floor 3 subnet scope. [Elevated permissions required]
- [ ] Access to Event Viewer on one affected device and one unaffected comparison device. [Elevated permissions required]
- [ ] Domain user test account from Finance OU.
- [ ] Correct DNS value confirmed: 10.10.0.10.
- [ ] Affected device list confirmed (example: FB055, FB056, FB057).
- [ ] End-user details captured: username, device name, first failure time, affected drive letters, and screenshot/text of error.

## 2) Procedure
1. Open DHCP management console on the DHCP server.
   Expected result: DHCP console opens with IPv4 scopes visible.

2. Navigate to IPv4 > Floor 3 subnet scope > Scope Options.
   Expected result: Option list for the Floor 3 scope is visible.

3. Open Option 006 (DNS Servers) for the Floor 3 scope.
   Expected result: Current DNS server list is displayed.

4. Remove old DNS server 10.10.3.250 from Option 006.
   Expected result: 10.10.3.250 is no longer listed.

5. Add DNS server 10.10.0.10 to Option 006 and apply.
   Expected result: Scope now shows DNS server 10.10.0.10 only. [Elevated permissions required]

6. On each affected device, open Command Prompt as administrator.
   Expected result: Elevated Command Prompt is open. [Elevated permissions required]

7. Run ipconfig /release.
   Expected result: Current IP lease is released.

8. Run ipconfig /renew.
   Expected result: Device receives a new DHCP lease.

9. Run ipconfig /all and verify DNS Servers shows 10.10.0.10.
   Expected result: Correct DNS server is present.

10. Run gpupdate /force.
    Expected result: Group Policy update completes without domain connectivity errors.

11. Sign out and sign in with a Finance user account.
    Expected result: Shared drives map and open normally.

12. Open Event Viewer > Windows Logs > System and filter for Event IDs 5719, 1014, 1058, 1030, 1129, 1500 in the current window.
    Expected result: No new 5719/1014/1058/1030/1129 errors, and GroupPolicy Event 1500 success appears.

## 3) Verification
1. On an affected device, run ipconfig /all after renewal.
   Expected result: DNS Servers is 10.10.0.10.

2. In Event Viewer > Windows Logs > System, check post-fix window.
   Expected result: No new Netlogon 5719 or DNS Client 1014 errors.

3. In Event Viewer > Windows Logs > System, check Group Policy events.
   Expected result: No new 1058/1030/1129 errors and at least one Event 1500 success.

4. With a Finance user session, open all required shared drives.
   Expected result: Drives open without remapping or path errors.

## 4) Rollback
1. Keep the corrected DNS value (10.10.0.10) in DHCP Scope Option 006.
   Expected result: Bad DNS value is not reintroduced.

2. If users still fail after DNS correction, remove affected devices from immediate production use and direct users to unaffected preconfigured device(s).
   Expected result: Finance users regain access through known-good devices.

3. Raise escalation to AD/DNS team with logs from affected device: Event IDs 5719, 1014, 1058, 1030, 1129 and device ipconfig /all output.
   Expected result: Tier-3 team receives complete evidence for deeper directory/network investigation.

## 5) Notes
- Verified root cause from RCA: Floor 3 DHCP scope referenced decommissioned DNS server 10.10.3.250.
- Verified unaffected comparison: device with DNS 10.10.0.10 processed Group Policy successfully (Event 1500).
- This failure pattern can present as missing shared drives, logon policy failures, or inability to reach file paths at sign-in.
- Preventive control: add DHCP scope DNS validation to migration cutover checklist and monitor for Event 5719/1058/1129 spikes after waves.
