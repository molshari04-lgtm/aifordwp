Title: Finance Team Cannot Access Shared Drives (Win11)
Version: 1.0
Date: 07/08/2026
Author: Sathishbabu
Reviewed: self
Status: draft
Change: initial version from RCA

# Runbook: Finance Team Cannot Access Shared Drives (Win11)

## Objective
Restore access to Finance mapped drives after migration by correcting DHCP-delivered DNS settings and refreshing client network/policy state.

## RCA Summary
- Confirmed root cause: Floor 3 DHCP scope option 006 included a decommissioned DNS server (`10.10.3.250`).
- Business impact: Affected clients could not reliably resolve domain controllers or file servers at sign-in.
- Observable pattern: Internal resources failed while general internet access still worked.

## Prerequisites Checklist (Complete Before You Start)
Access checklist:
- [ ] You can sign in to the DHCP server with an account that can edit IPv4 scope options.
- [ ] You can open `Server Manager > Tools > DHCP` on the DHCP server.
- [ ] You can run elevated Command Prompt on at least one affected user PC.
- [ ] You can open `Event Viewer > Windows Logs > System` on at least one affected user PC.
- [ ] You have one unaffected comparison PC available in the same office.

Tools checklist:
- [ ] DHCP console (`dhcpmgmt.msc`) is available.
- [ ] Command Prompt (Run as administrator) is available on affected and comparison PCs.
- [ ] Event Viewer (`eventvwr.msc`) is available.
- [ ] Network adapter control panel path opens: `Win + R > ncpa.cpl`.

Mandatory end-user information checklist:
- [ ] User full name and work username.
- [ ] Device name of affected PC.
- [ ] Impacted drive letters and path (example: `S:` or `P:`).
- [ ] Exact error text or screenshot.
- [ ] First observed time of failure.
- [ ] Office location/floor and whether nearby users are also affected.
- [ ] Confirmation whether restart and sign-out/sign-in were already attempted.

Technical reference checklist:
- [ ] Known-good DNS value confirmed as `10.10.0.10`.
- [ ] Suspected bad DNS value confirmed as `10.10.3.250`.

## Recovery Procedure (Junior Engineer, Step-by-Step)
1. Confirm user impact details before making changes.
Location: Ticket record and user call/chat.
Action: Validate impacted users, devices, drive letters, and first-failure time.
Expected: You can clearly identify affected floor/subnet and at least one affected endpoint.

2. Capture pre-change client network state.
Location: `Affected PC > Start > type cmd > Run as administrator`.
Run:
```cmd
ipconfig /all
```
Expected: You can see current DNS server value; save output to ticket notes.

3. Capture pre-change failure events.
Location: `Affected PC > Event Viewer > Windows Logs > System > Filter Current Log...`.
Filter values:
- Logged: `Last 2 hours`
- Event IDs: `5719,1014,1058,1030,1129`
Expected: Relevant pre-fix events are visible; note the latest timestamp.

4. Open DHCP scope options.
Location: `DHCP Server > Server Manager > Tools > DHCP > IPv4 > Floor 3 Scope > Scope Options`.
Expected: Scope options list opens.

5. Correct DNS server setting in Option 006.
Location: same DHCP window, option `006 DNS Servers`.
Action: Remove `10.10.3.250`; keep/add `10.10.0.10`; click `OK`/`Apply`.
Expected: Option 006 shows only approved DNS value(s).

6. Refresh lease and DNS on affected PC.
Location: `Affected PC > elevated Command Prompt`.
Run:
```cmd
ipconfig /release
ipconfig /renew
ipconfig /all
```
Expected: DNS Servers now display `10.10.0.10`.

7. Refresh policy processing.
Location: same elevated Command Prompt.
Run:
```cmd
gpupdate /force
```
Expected: Policy update completes without DC connectivity errors.

8. Recreate user session and test drive access.
Location: `Affected PC > Start menu profile icon > Sign out`, then sign in again.
Test location: `File Explorer > This PC`.
Expected: Finance mapped drives open successfully.

9. Confirm no new failure logs after fix.
Location: `Affected PC > Event Viewer > Windows Logs > System > Filter Current Log...`.
Filter values:
- Logged: `Last 30 minutes`
- Event IDs: `5719,1014,1058,1030,1129`
Expected: No new occurrences after fix timestamp.

10. Capture post-change success evidence.
Location A: `Affected PC > Event Viewer > Windows Logs > System`.
Filter values: Event source `GroupPolicy`, Event ID `1500`, Logged `Last 30 minutes`.
Location B: `File Explorer > This PC`.
Expected: GroupPolicy success event present and required drives are accessible.

## Verification Checklist (Junior Engineer)
1. Verify DHCP scope DNS value.
Location: `Server Manager > Tools > DHCP > IPv4 > Floor 3 Scope > Scope Options > 006 DNS Servers`.
Expected: Only approved DNS value `10.10.0.10` is present.

2. Verify client lease and DNS value on one affected endpoint.
Location: `Affected PC > Start > type cmd > Run as administrator`.
Run:
```cmd
ipconfig /all
```
Expected: Active adapter shows `DNS Servers . . . . . . . . . . : 10.10.0.10`.

3. Verify domain controller name resolution from the same endpoint.
Location: same elevated Command Prompt.
Run:
```cmd
nslookup FINBRIDGE-DC01.finbridge.local
```
Expected: Command returns an IP address and no timeout/server failure.

4. Verify post-fix error events are no longer generated.
Location: `Affected PC > Event Viewer > Windows Logs > System > Filter Current Log...`.
Filter values:
- Logged: `Last 30 minutes`
- Event IDs: `5719,1014,1058,1030,1129`
Expected: No new events after fix timestamp.

5. Verify policy processing success event.
Location: `Affected PC > Event Viewer > Windows Logs > System > Filter Current Log...`.
Filter values:
- Logged: `Last 30 minutes`
- Event source: `GroupPolicy`
- Event ID: `1500`
Expected: At least one success event after DNS correction.

6. Verify business function.
Location: `Affected PC > File Explorer > This PC`.
Expected: Finance user opens required mapped drives (for example `S:` and `P:`) without errors.

## Rollback (Under 3 Minutes, No Extra Guidance)
Use this only if DHCP correction is done but the current user still cannot access drives.

1. Set temporary manual DNS on the affected PC.
Location: `Affected PC > Win + R > ncpa.cpl > active adapter > Properties > Internet Protocol Version 4 (TCP/IPv4) > Properties`.
Action: Select `Use the following DNS server addresses` and enter `Preferred DNS server: 10.10.0.10`.
Expected: DNS override saved on that PC.

2. Refresh local name cache.
Location: `Affected PC > Start > type cmd > Run as administrator`.
Run:
```cmd
ipconfig /flushdns
```
Expected: `Successfully flushed the DNS Resolver Cache`.

3. Rebuild user policy session.
Location: same elevated Command Prompt.
Run:
```cmd
gpupdate /force
```
Expected: User and computer policy update completes.

4. Re-test mapped drives immediately.
Location: `File Explorer > This PC`.
Expected: `S:`/`P:` open successfully.

5. If still failing, collect and escalate.
Location for logs: `Event Viewer > Windows Logs > System` (Event IDs `5719,1014,1058,1030,1129`).
Action: Export filtered view and escalate to AD/DNS team with `ipconfig /all` output and error screenshot.

## Prevention
- Add DHCP scope DNS validation to migration cutover checklist.
- Add post-change health check: lease, DNS lookup to domain controller, and shared drive access test.
- Alert on spikes of Event IDs `5719` and `1129` following migration waves.
