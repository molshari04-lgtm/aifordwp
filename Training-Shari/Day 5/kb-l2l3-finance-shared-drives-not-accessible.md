# KB (L2/L3): Finance Team Cannot Access Shared Drives (Win11)

Version: v1.0  
Date: 10/08/2026  
Status: Active

## Scope
Use this article when users report:
- Internet works, but Finance shared drives do not open.
- Mapped drives are missing at sign-in.
- Multiple users in the same floor/segment are affected.

## Incident RCA
Confirmed cause in incident: DHCP scope for Floor 3 published decommissioned DNS server `10.10.3.250` in Option 006. Affected clients received invalid DNS, failed domain controller resolution, and then failed Group Policy and mapped drive processing at logon.

## Incident Window Evidence (FAULT-A)
Affected endpoint sample: `DESKTOP-FB031` (startup window 07:40-07:55)
- `07:40:08` Netlogon Event `5719`: no domain controller available.
- `07:40:09` GroupPolicy Event `1058`: cannot access `\\FINBRIDGE-DC01\sysvol\...\gpt.ini`.
- `07:40:10` GroupPolicy Event `1030`: cannot query GPO list.
- `07:40:12` GroupPolicy Event `1129`: no network connectivity to domain controller.
- `07:41:05` DNS Client Event `1014`: DC FQDN resolution timeout.
- `07:42:18` DHCP Client Event `50036`: DNS assigned as old/decommissioned value.

Unaffected comparison sample: `DESKTOP-FB029`
- `07:40:05` DHCP Client Event `50036`: DNS assigned `10.10.0.10` (correct).
- `07:40:11` GroupPolicy Event `1500`: policy processed successfully.

Server-side DHCP comparison confirms scope fault:
- Affected Finance devices received old DNS values from scope.
- Manually preconfigured comparison device received correct DNS and remained healthy.

## Evidence Pattern (What Confirms This RCA)
- Netlogon Event ID `5719`: secure channel / DC unavailable.
- DNS Client Event ID `1014`: name resolution timeout for domain controller FQDN.
- GroupPolicy Event IDs `1058`, `1030`, `1129`: SYSVOL/GPO processing failure due to no DC connectivity.
- DHCP event/logs show wrong DNS assignment (`10.10.3.250`) to affected clients.
- Comparison device with DNS `10.10.0.10` shows normal policy processing (for example Event ID `1500`) and working mapped drives.

## Technical Triage Workflow
1. Confirm scope of impact.
- Check if affected users are in the same subnet/floor.
- Check if unaffected users are on different scope or static DNS.

2. Validate client DNS on one affected endpoint:
```cmd
ipconfig /all
```
- Record DNS Servers value and lease details.

3. Validate event sequence on affected endpoint (System log):
- `5719` -> `1014` -> `1058/1030/1129` around logon window.

4. Validate DHCP scope option on server:
- DHCP Console -> IPv4 -> Floor 3 Scope -> Scope Options -> 006 DNS Servers.
- Confirm only valid corporate DNS (expected `10.10.0.10`).

5. Run comparison check on an unaffected device:
```cmd
ipconfig /all
```
- Confirm DNS mismatch between affected and unaffected endpoints.

## Resolution Steps
1. Correct DHCP Scope Option 006.
- Remove `10.10.3.250`.
- Set DNS to `10.10.0.10` (and any approved secondary, if documented).

2. Refresh client leases on impacted devices:
```cmd
ipconfig /release
ipconfig /renew
```

3. Validate updated DNS on clients:
```cmd
ipconfig /all
```

4. Refresh policy and user context:
```cmd
gpupdate /force
```
- Sign out/in once for the affected user.

5. Validate shared drives open successfully.

## Verification Criteria
- Client DNS shows corrected value(s).
- No new `5719`, `1014`, `1058`, `1030`, `1129` after the fix window.
- At least one successful GP processing event present post-fix.
- Finance user can open required shared drives without manual remapping.

## Escalation Boundary
Escalate to AD/DNS platform team if any condition applies:
- Correct DNS is delivered but failures continue.
- Event pattern does not match this RCA.
- Impact extends beyond one subnet/floor after scope correction.
- Multiple old DNS values are observed from DHCP logs and scope history cannot confirm authoritative intended state.

Escalation package must include:
- `ipconfig /all` from one affected and one unaffected endpoint.
- Event log export around failure window.
- DHCP scope Option 006 screenshot before and after correction.
- List of affected users/devices and first observed timestamp.

## Preventive Controls
- Add mandatory DNS validation to every migration/cutover checklist.
- Add synthetic test after DHCP changes:
  1. Obtain lease on test endpoint
  2. Resolve domain controller FQDN
  3. Access SYSVOL and one Finance shared path
- Create alert threshold for spikes in Event IDs `5719` and `1129`.
