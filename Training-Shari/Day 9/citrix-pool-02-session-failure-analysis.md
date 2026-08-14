# Citrix Pool-02 Session Launch Failure Analysis

**Analysis date:** 2026-08-14  
**Affected service:** Citrix virtual desktop delivery  
**Affected pool:** `FinBridge-VDI-Pool-02`  
**Unaffected comparison pool:** `FinBridge-VDI-Pool-01`

## 1. Scope and observed state

- 22 of 30 users on `FinBridge-VDI-Pool-02` are affected.
- `FinBridge-VDI-Pool-01`, in the same Citrix site, is unaffected.
- Pool-02 has 25 machines: 3 registered, 22 unregistered, and 0 in maintenance mode.
- Pool-01 has 20 machines: 19 registered and 1 unregistered.
- The broker waits 30,000 ms for a machine registration response and then records:

  `Session launch FAILED: error 1030 'No machines available in the desktop group'`

- Sample Pool-02 VDAs report failed registration attempts against `dc-vdi-02.finbridge.local:80` with `connection refused`.
- On `dc-vdi-02`, the Citrix Broker Service is stopped. It was last known running at 23:40 on the previous day.
- A Windows Update was installed on `dc-vdi-02` at 00:15 on the current day. A reboot is required, but the host has not been rebooted.
- On `dc-vdi-01`, which serves Pool-01, the Citrix Broker Service is running and the controller has 14 days of uptime.

## 2. Error-code handling

The supplied broker log explicitly pairs Citrix error `1030` with the text `No machines available in the desktop group`. That exact logged text is used in this analysis. No broader vendor meaning for error 1030 is assumed or required to reach the ranking below.

## 3. Ranked likely causes

### 1. Citrix Broker Service stopped on `dc-vdi-02`

**Why it fits the evidence**

- This is the strongest direct health failure in the supplied evidence.
- Pool-02 VDAs are attempting to contact `dc-vdi-02` and receive `connection refused`, which is consistent with the expected service endpoint not accepting connections.
- Pool-02 has 22 unregistered machines, matching the number of affected users, while the comparison pool served by the healthy controller is almost fully registered.
- The launch failure follows a timeout waiting for a machine registration response.

**Fastest confirming or eliminating check**

On `dc-vdi-02`, check the Citrix Broker Service state and the expected listener, then start the service during an approved change window. Recheck Pool-02 registration immediately afterward. The hypothesis is confirmed if the service stays running, the endpoint accepts connections, and Pool-02 machines begin registering. It is weakened or eliminated if registrations remain unchanged despite a healthy service and reachable endpoint.

**Specific remediation if confirmed**

Restore the Citrix Broker Service on `dc-vdi-02`, confirm it is configured for its approved automatic startup mode, verify its dependencies and listener, and allow or trigger the Pool-02 VDAs to re-register. Because the controller has a pending reboot, use the ordered remediation in section 5 rather than treating a manual service start as the complete fix.

### 2. Incomplete Windows Update/reboot state on `dc-vdi-02`

**Why it fits the evidence**

- The update was installed after the service was last known running.
- The controller has a reboot-required flag but has not been rebooted.
- The Broker Service is now stopped. This timing makes the incomplete update state a plausible initiating condition for the service outage.
- The evidence does not prove that the update stopped the service, so this remains a likely trigger rather than a confirmed root cause.

**Fastest confirming or eliminating check**

Review Windows Update history, System and Citrix event logs around 23:40-00:15, and the Broker Service exit/startup events. Perform the controlled reboot, then verify whether the Broker Service starts normally and remains stable. A clean post-reboot service recovery supports this hypothesis; an immediate repeat failure points to another service, dependency, or configuration fault.

**Specific remediation if confirmed**

Complete the pending reboot under change control, verify all Citrix controller services start successfully, and investigate or roll back the specific update only if vendor guidance and event evidence identify it as incompatible. Do not remove an update solely because it preceded the incident.

### 3. Listener, binding, or host firewall failure on `dc-vdi-02` port 80

**Why it fits the evidence**

- Two sampled Pool-02 VDAs receive `connection refused` from `dc-vdi-02.finbridge.local:80`.
- A refusal indicates that the destination was reached but the requested endpoint did not accept the connection; a missing listener, rejected binding, or host-level rule could produce this symptom.
- This ranks below the stopped-service hypothesis because the known stopped Broker Service already explains why its expected endpoint may not be listening.

**Fastest confirming or eliminating check**

From an affected VDA, run `Test-NetConnection dc-vdi-02.finbridge.local -Port 80`. On the controller, verify the approved Citrix listener/binding and inspect host firewall logging. Repeat the test after restoring the Broker Service. If connectivity succeeds after service recovery, a separate network or firewall cause is eliminated.

**Specific remediation if confirmed**

Restore the approved Citrix listener or binding and correct only the controller-side firewall rule shown to be rejecting the traffic. Do not create a broad allow rule. Validate from an affected VDA and confirm successful registration.

## 4. Finalized working hypothesis

The Pool-02 launch failure is caused by the Citrix Broker Service being stopped on `dc-vdi-02`, preventing Pool-02 VDAs from registering and leaving the desktop group without sufficient registered machines for the affected launches.

The pending Windows Update reboot is the most likely trigger for the stopped-service condition, but the supplied data does not prove that causal link. Event-log and post-reboot checks are required before attributing the service stop to the update itself.

## 5. Ordered remediation procedure

1. Record the current service state, update history, reboot-required state, and relevant System/Application/Citrix events from `dc-vdi-02` so evidence is preserved.
2. Confirm that `dc-vdi-01` remains healthy and that Pool-01 sessions are unaffected. Do not change Pool-01 or its controller.
3. Notify service owners of the Pool-02 recovery action and stop new administrative changes to `dc-vdi-02` during remediation.
4. Perform a controlled reboot of `dc-vdi-02` to complete the pending Windows Update operation.
5. After restart, verify that the Citrix Broker Service is running and set to the approved automatic startup mode. Check its dependencies and Citrix/System event logs for startup errors.
6. Verify that `dc-vdi-02` is accepting connections on the configured registration endpoint. From an affected Pool-02 VDA, test `dc-vdi-02.finbridge.local` on TCP port 80.
7. Monitor the Pool-02 catalog for automatic VDA re-registration. If individual VDAs do not re-register after controller connectivity is restored, restart the Citrix Desktop Service on those VDAs in controlled batches and inspect their registration events.
8. Confirm that the Pool-02 registered count returns to the expected operational baseline and that the unregistered count no longer reflects the 22-machine incident condition.
9. Launch a test desktop from Pool-02 with an authorized test account and confirm that no 30-second registration timeout or error 1030 is recorded.
10. Monitor service state, registration counts, and launch success for the agreed observation period before closing the incident.

If the Broker Service does not start after reboot, do not repeatedly reboot. Capture its startup error, validate dependencies and service identity/configuration, and escalate with the Citrix and Windows event evidence. If the service runs but port 80 remains refused, investigate the listener/binding and host firewall path represented by ranked cause 3.

## 6. Resolution verification

Resolution is confirmed only when all of the following are true:

- Citrix Broker Service on `dc-vdi-02` is running and remains running.
- The configured registration endpoint is reachable from Pool-02 VDAs.
- Pool-02 machines re-register and the catalog returns to its expected healthy registration baseline.
- A Pool-02 test launch succeeds.
- The broker log no longer shows `Timeout waiting for machine registration response (30000ms exceeded)` or `error 1030 'No machines available in the desktop group'` for the test.
- Pool-01 remains healthy and unaffected.

## 7. Preventive action

Implement controller and catalog monitoring that alerts on:

- Citrix Broker Service stopped or failed startup on either controller.
- A material rise in unregistered machines by pool.
- Registration endpoint failure from representative VDAs.
- Pending reboot state beyond the approved maintenance window.

Add a post-patching validation gate requiring controller service health, endpoint connectivity, catalog registration counts, and a synthetic session launch before maintenance is closed. Review Pool-02 controller dependency and failover design so a single controller service outage cannot remove registration capacity for most of the pool.