Assessment of FAULT-A:

Most likely cause (verified): Floor 3 DHCP scope still referenced decommissioned DNS server values after migration cutover, causing affected Win11 Finance endpoints to fail domain controller name resolution at startup. Group Policy then failed as a downstream effect.

Why this fits the evidence:
1. Network stack starts, then DC discovery fails:
- 07:40:02 Service Control Manager Event 7036: Network Location Awareness running.
- 07:40:08 Netlogon Event 5719: secure channel setup failed, DC unavailable.

2. Group Policy fails immediately after DC discovery failure:
- 07:40:09 and 07:40:11 GroupPolicy Event 1058: cannot access `\\FINBRIDGE-DC01\sysvol\...\gpt.ini`.
- 07:40:10 GroupPolicy Event 1030: cannot query GPO list.
- 07:40:12 and 07:44:01 GroupPolicy Event 1129: no DC connectivity.

3. DNS timeout confirms name resolution root layer failure:
- 07:41:05 DNS Client Event 1014: `FINBRIDGE-DC01.finbridge.local` resolution timed out.

4. DHCP delivered decommissioned DNS to affected clients:
- 07:42:18 DHCP Client Event 50036 on affected endpoint shows DNS `10.10.3.250`.
- Server-side DHCP comparison also shows old DNS values on affected set (for example `172.16.5.5`) versus correct new DNS `10.10.0.10` on unaffected/manual baseline device.

5. Healthy comparison host proves control case:
- Unaffected DESKTOP-FB029 at 07:40:05 received DNS `10.10.0.10`.
- Same host at 07:40:11 logged GroupPolicy Event 1500 success.

Scope:
- Affected: 3 of 4 Finance OU machines on Floor 3.
- Unaffected: manually preconfigured comparison machine(s) with correct DNS.

Immediate recovery actions:
1. Correct DHCP Scope Option 006 for Floor 3 to approved DNS (`10.10.0.10` and approved secondary only).
2. Force lease renew on affected clients.
3. Run GP refresh and confirm no new 1058/1030/1129 while success events return.

Preventive actions:
1. Add mandatory DHCP scope DNS validation before and after migration waves.
2. Add synthetic test sequence: obtain lease -> resolve DC FQDN -> access SYSVOL path.
3. Alert on spikes of Netlogon 5719 and GroupPolicy 1058/1129 post-change.
