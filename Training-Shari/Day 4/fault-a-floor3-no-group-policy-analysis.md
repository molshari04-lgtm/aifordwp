Assessment of FAULT-A:

Most likely cause (verified): DHCP scope misconfiguration on Floor 3 assigned a decommissioned DNS server, so affected Win11 clients could not resolve domain controllers at startup and Group Policy failed.

Why this fits the evidence:
1. DC discovery failed first:
- 07:40:08 Netlogon Event 5719: no secure channel, no DC available.
2. SYSVOL path then failed:
- 07:40:09 and 07:40:11 GroupPolicy Event 1058 with `\\FINBRIDGE-DC01\sysvol\...` inaccessible.
- 07:40:10 GroupPolicy Event 1030 unable to query GPO list.
- 07:40:12 and 07:44:01 GroupPolicy Event 1129 no DC connectivity.
3. DNS timeout confirms name resolution problem:
- 07:41:05 DNS Client Event 1014 for `FINBRIDGE-DC01.finbridge.local`.
4. DHCP handed out wrong DNS:
- 07:42:18 DHCP Event 50036 assigned DNS `10.10.3.250` (old/decommissioned).
5. Healthy comparison proves control case:
- Unaffected FB029 received DNS `10.10.0.10` and had GroupPolicy Event 1500 success.

Scope:
- Affected: 3 of 4 Finance OU machines on Floor 3 using old DNS from DHCP.
- Unaffected: manually preconfigured machine(s) with correct DNS.

Immediate recovery actions:
1. Update Floor 3 DHCP scope option 006 to `10.10.0.10`.
2. Force lease renew on affected clients.
3. Run GP refresh and verify Event 1500 success plus no new 1058/1030/1129.

Preventive actions:
1. Add pre-cutover DHCP scope validation checklist for DNS changes.
2. Add post-change synthetic test: DHCP lease + DC DNS lookup + SYSVOL reachability.
3. Alert on spike of Netlogon 5719 and GroupPolicy 1058/1129 after migration waves.
