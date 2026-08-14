# Root Cause Analysis: Citrix Pool-02 Session Launch Failure

**RCA date:** 2026-08-14  
**Service:** Citrix virtual desktop delivery  
**Affected pool:** `FinBridge-VDI-Pool-02`  
**Status:** Evidence-based root cause identified; operational resolution must be confirmed by the verification checks below

## 1. Executive summary

Twenty-two of 30 users on `FinBridge-VDI-Pool-02` could not launch sessions. The broker waited 30 seconds for a machine registration response and recorded error 1030 with the exact message `No machines available in the desktop group`.

The immediate technical cause is that the Citrix Broker Service on the controller used by Pool-02, `dc-vdi-02`, is stopped. Pool-02 has 22 unregistered machines, and sampled VDAs report that connections to `dc-vdi-02.finbridge.local:80` are refused. The comparison environment remains healthy: Pool-01 has 19 of 20 machines registered, and the Broker Service on its controller, `dc-vdi-01`, is running.

A Windows Update was installed on `dc-vdi-02` after the Broker Service was last known running, and the controller is awaiting a reboot. This is the leading trigger hypothesis, but the supplied evidence does not establish that the update caused the service to stop. That attribution requires event-log correlation and post-reboot behavior.

## 2. Impact and scope

| Item | Observed state |
|---|---|
| Affected users | 22 of 30 |
| Affected pool | `FinBridge-VDI-Pool-02` |
| Unaffected pool | `FinBridge-VDI-Pool-01` |
| Pool-02 machine state | 25 provisioned; 3 registered; 22 unregistered; 0 in maintenance mode |
| Pool-01 machine state | 20 provisioned; 19 registered; 1 unregistered |
| User-visible effect | Session launch failure |
| Broker result | Error 1030: `No machines available in the desktop group` |

The incident is pool-specific rather than site-wide because Pool-01 in the same site remains operational.

## 3. Supporting evidence

### Broker evidence

- 08:58:03: Session launch requested for user `jsmith` on Pool-02.
- 08:58:04: Broker queried available machines in Pool-02.
- 08:58:34: Broker timed out waiting for a machine registration response after 30,000 ms.
- 08:58:34: Launch failed with `error 1030 'No machines available in the desktop group'`.

The RCA uses the exact error text present in the supplied log. It does not infer any additional undocumented meaning for error 1030.

### Catalog evidence

- Pool-02: only 3 of 25 machines are registered; 22 are unregistered.
- Pool-01: 19 of 20 machines are registered.
- No Pool-02 machines are in maintenance mode, eliminating catalog maintenance mode as an explanation for the 22-machine registration loss.

### VDA registration evidence

- `VDI-P02-014`: registration attempt at 06:15:22 failed because it could not contact the Delivery Controller; connection to `dc-vdi-02.finbridge.local:80` was refused.
- `VDI-P02-017`: registration attempt at 06:16:01 failed with the same controller and connection-refused result.

These are samples, so they directly prove the symptom for those machines and support, but do not individually prove, the state of every unregistered VDA.

### Controller evidence

- `dc-vdi-02`: Citrix Broker Service stopped; last known running at 23:40 on the previous day.
- `dc-vdi-02`: Windows Update installed at 00:15 on the current day; reboot-required flag set; host not rebooted.
- `dc-vdi-01`: Citrix Broker Service running; uptime 14 days; serves the healthy Pool-01 comparison group.

## 4. Timeline

The source data provides times but no explicit incident calendar date. The relative labels below preserve that limitation.

| Relative time | Event |
|---|---|
| Previous day 23:40 | Citrix Broker Service on `dc-vdi-02` last known running |
| Current day 00:15 | Windows Update installed on `dc-vdi-02`; reboot required but not completed |
| Current day 06:15:22 | `VDI-P02-014` registration fails; controller port 80 connection refused |
| Current day 06:16:01 | `VDI-P02-017` registration fails with the same result |
| Current day 08:58:03 | Pool-02 launch requested for `jsmith` |
| Current day 08:58:04 | Broker queries Pool-02 for an available machine |
| Current day 08:58:34 | Registration response times out after 30 seconds; launch fails with error 1030 |
| At investigation | Pool-02 has 3 registered and 22 unregistered machines; Broker Service on `dc-vdi-02` is stopped |
| At investigation | Pool-01 has 19 registered and 1 unregistered machine; Broker Service on `dc-vdi-01` is running |

## 5. Causal analysis

### Confirmed immediate cause

The Citrix Broker Service on `dc-vdi-02` is stopped. The controller endpoint used by sampled Pool-02 VDAs refuses connections, Pool-02 registrations have collapsed, and launches fail after waiting for registration responses.

### Probable initiating factor

The incomplete Windows Update/reboot cycle on `dc-vdi-02` is the most likely trigger because the update occurred after the service was last known running and the host remains in a reboot-required state. The evidence does not show the service stop event, update identity, service exit code, or event-log sequence, so the update must not be recorded as a confirmed cause without those checks.

### Contributing control gap

The incident data shows that a stopped controller service and a rise to 22 unregistered machines persisted until user launches failed. This supports a monitoring or response gap. Whether alerts existed but were not acted upon is not established by the supplied data.

## 6. Five Whys

1. **Why could affected users not launch Pool-02 desktops?**  
   The broker reported no machines available in the desktop group after a 30-second registration-response timeout.

2. **Why were machines unavailable to the broker?**  
   Pool-02 had only 3 registered machines and 22 unregistered machines.

3. **Why were Pool-02 machines unregistered?**  
   Sampled Pool-02 VDAs could not contact their Delivery Controller at `dc-vdi-02.finbridge.local:80`; the connection was refused.

4. **Why was the controller endpoint not accepting those registration connections?**  
   The Citrix Broker Service on `dc-vdi-02` was stopped. This is the confirmed immediate technical cause.

5. **Why was the Broker Service stopped and not restored before user impact?**  
   A Windows Update had been installed and a reboot was pending, making an incomplete maintenance cycle the leading trigger hypothesis. The exact service-stop mechanism and whether monitoring failed or was not acted upon are not proven by the supplied evidence and require event and alert review.

## 7. Root cause statement

The Pool-02 session launch incident was caused by the Citrix Broker Service being stopped on `dc-vdi-02`. This prevented Pool-02 VDAs from registering, resulting in 22 unregistered machines and broker launch failures after registration-response timeouts.

The pending post-update reboot on `dc-vdi-02` is recorded as the probable trigger, not a confirmed underlying cause, until event-log correlation confirms the sequence.

## 8. Corrective action and order of operations

1. Preserve `dc-vdi-02` System, Application, Citrix, service-state, Windows Update, and reboot-pending evidence.
2. Confirm `dc-vdi-01` and Pool-01 remain healthy; make no changes to the unaffected path.
3. Place the recovery under change control and notify the Pool-02 service owner.
4. Reboot `dc-vdi-02` in a controlled maintenance window to complete the pending update operation.
5. Confirm the Citrix Broker Service starts, remains running, and uses its approved automatic startup setting. Review dependencies and startup events.
6. From a Pool-02 VDA, verify TCP connectivity to `dc-vdi-02.finbridge.local` on the configured port 80 endpoint.
7. Monitor Pool-02 VDAs as they re-register. Restart the Citrix Desktop Service only on VDAs that remain unregistered after controller connectivity is healthy, using controlled batches.
8. Confirm catalog registration returns to the expected operational baseline.
9. Complete an authorized Pool-02 test launch and inspect the broker log for a successful launch without the 30-second timeout or error 1030.
10. Observe controller service stability, registration counts, and launch success before incident closure.

If the Broker Service fails to start, capture the exact service and dependency errors before further action. If it starts but the endpoint remains refused, validate the Citrix listener/binding and controller host firewall. Update rollback is appropriate only when event evidence and vendor guidance identify the installed update as causal.

## 9. Verification and closure criteria

- Broker Service on `dc-vdi-02` is running and stable.
- The registration endpoint is reachable from affected-pool VDAs.
- Pool-02 registration count returns to the agreed healthy baseline.
- An authorized Pool-02 session launches successfully.
- No new Pool-02 registration-response timeout or matching error 1030 occurs during the observation period.
- Pool-01 remains healthy.
- Event review either confirms the initiating factor or records it as unresolved for problem management.

## 10. Preventive and follow-up actions

| Priority | Action | Success measure |
|---|---|---|
| Immediate | Alert on Citrix Broker Service stop/failure on every Delivery Controller | Alert generated and routed within the agreed monitoring interval |
| Immediate | Alert on abnormal unregistered-machine count or percentage per pool | Pool-specific threshold tested and incident routing verified |
| Immediate | Add post-patch checks for service state, registration endpoint, catalog health, and synthetic launch | Maintenance cannot close until all checks pass |
| Short term | Enforce reboot completion within the approved patch window | No controller remains reboot-pending beyond the window without an approved exception |
| Short term | Review Broker Service recovery and approved automatic-start configuration | Service recovery behavior documented and tested |
| Short term | Review Pool-02 controller dependency and failover design | Documented test demonstrates that one controller service outage does not remove most pool registration capacity |
| Problem management | Correlate update, service-control, Citrix, and monitoring events | Trigger and detection gap classified as confirmed or unknown with evidence |

## 11. Evidence still required for final problem closure

- Citrix and Windows event logs showing when and why the Broker Service stopped.
- Identity and status of the update installed at 00:15.
- Post-reboot Broker Service behavior and listener state.
- Pool-02 registration recovery trend after controller restoration.
- Successful test-launch evidence.
- Monitoring and alert history for the controller service and catalog registration decline.