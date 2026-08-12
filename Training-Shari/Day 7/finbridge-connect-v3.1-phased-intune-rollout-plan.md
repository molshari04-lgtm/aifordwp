# FinBridge Connect v3.1 Phased Intune Deployment Plan

Date: 2026-08-12  
Owner: DWP Engineering (Endpoint + Service Operations + Finance IT Liaison)  
Scope: 10,000 Windows 11 endpoints, 3-week deadline

## 1. RING STRUCTURE

### Overall 3-week sequence

- Week 1: Ring 0 (Finance priority) then Ring 1 (Main Pilot)
- Week 2: Ring 2 (Early)
- Week 3: Ring 3 (Broad)

### Ring design

| Ring | Size | Duration | Who to include | Purpose | Intune assignment group type |
|---|---:|---|---|---|---|
| Ring 1 (Pilot) | 200 devices (2.0%) | 3 full business days minimum (72 hours monitoring after last device shows Installed/Pending) | Cross-functional technical pilot: IT engineers, service desk power users, 20 finance users not in Ring 0, mixed device models, all major office locations, include at least 20 devices from 4GB RAM cohort | Validate install command behavior, detection rule stability, restart behavior, and support readiness before business-scale impact | Microsoft Entra ID security group, device-based, manually assigned static membership. Intune app assignment type: Required |
| Ring 2 (Early) | 2,300 devices (23.0%) | 5 business days minimum (including full Monday-Friday usage cycle) | Remaining Finance population not already deployed, then high-business-impact teams (Ops, Contact Center leads, key managers), plus representative users from each business unit | Confirm business-process compatibility and scaled install health before broad fleet assignment | Microsoft Entra ID security groups, device-based, staged static groups by business unit. Intune app assignment type: Required |
| Ring 3 (Broad) | 7,500 devices (75.0%) | Remaining window in week 3 with daily checkpoints; complete by day 15 | All remaining Win11 endpoints, excluding temporary hold/isolation groups | Complete enterprise rollout with controlled wave progression and rollback safety preserved | Microsoft Entra ID dynamic device group for remaining eligible Win11 devices, with explicit exclusion groups for hold devices and rollback cohorts. Intune app assignment type: Required |

### Ring-specific inclusion controls

- Create a dedicated at-risk hardware group: DWP-Win11-4GB-AtRisk (about 500 devices).
- Distribute at-risk devices intentionally:
- Ring 1: 20 at-risk devices
- Ring 2: additional 130 at-risk devices
- Ring 3: remaining at-risk devices only after Ring 2 at-risk criteria pass
- Keep all rings device-targeted (not user-targeted) to control endpoint compliance and reduce shared-device ambiguity.

## 2. ADVANCE CRITERIA

Advance decisions are made only after the minimum monitoring period is met and Intune reporting data is stable for 2 consecutive reporting snapshots.

### Ring 1 to Ring 2 (go/no-go criteria)

| Criterion | Threshold to advance | How measured | Time-bound requirement |
|---|---|---|---|
| Install success rate | At least 97.0% Installed | Intune: Apps > Windows > FinBridge Connect v3.1 > Monitor > Device install status. Formula: Installed / (Installed + Failed + Not installed where Required) | Evaluate after minimum 72 hours monitoring from assignment, and after at least 2 device check-in cycles |
| Error rate | No more than 2.0% Failed | Same Intune Device install status view | Must remain below threshold for last 24 hours of Ring 1 monitoring window |
| User-reported issue rate | No more than 4.0 tickets per 100 deployed devices in 72 hours | Service desk incident queue tagged FINBRIDGE-V31, normalized by deployed device count | Evaluate at 72-hour mark; must not trend upward in final 24 hours |
| Monitoring period | Minimum 72 hours after initial assignment and at least 24 hours after 95% of ring shows Installed or Failed | Intune install status timestamps + support queue timestamps | Mandatory minimum before any promotion decision |

### Ring 2 to Ring 3 (go/no-go criteria)

| Criterion | Threshold to advance | How measured | Time-bound requirement |
|---|---|---|---|
| Install success rate | At least 98.0% Installed | Intune Device install status (same method) | Evaluate after minimum 5 business days in Ring 2 |
| Error rate | No more than 1.5% Failed | Intune Device install status | Must stay at or below threshold for final 48 hours of Ring 2 window |
| User-reported issue rate | No more than 2.5 tickets per 100 deployed devices over 5 business days | Service desk incidents tagged FINBRIDGE-V31 and severity-classified | Must include at least 1 full weekday peak usage period |
| Monitoring period | Minimum 5 business days | Intune + incident telemetry | Mandatory minimum before Ring 3 release |

### Hold condition (pause without full rollback)

Trigger a ring pause (no new assignments) if either condition occurs:

- Failed installs rise above 3.0% but stay below rollback threshold, or
- User issue rate exceeds advance threshold by at least 30% for one 24-hour window

Specific example:

- Ring 2 reaches 3.2% Failed mainly on one Lenovo model with older BIOS. Action: pause new Ring 2 expansions, isolate affected model into hold group, continue unaffected devices after targeted remediation validation.

## 3. ROLLBACK TRIGGERS

### Trigger matrix

| Trigger type | Explicit rollback trigger | Decision owner | Decision window |
|---|---|---|---|
| Install failure rate | If Failed is 8.0% or higher for any active ring within a rolling 12-hour window after assignment | DWP Change Manager (final approval) with Endpoint Lead recommendation | 60 minutes from trigger detection |
| Application crash rate | If app crash incidents attributable to FinBridge v3.1 are 2.0 or more crashes per 100 active devices in a rolling 24-hour window, confirmed by endpoint telemetry and ticket correlation | Endpoint Engineering Lead + Service Operations Manager | 2 hours from threshold confirmation |
| Business-critical failure | Immediate rollback if Finance cannot complete payment release workflow due to app failure on at least 2 independent devices in production use, validated by Finance IT liaison | Major Incident Manager (immediate authority) | Immediate decision, execute within 30 minutes |
| 4GB RAM at-risk failures | If at-risk group exceeds 12.0% Failed or Severe performance incidents exceed 8 per 100 at-risk devices in 24 hours | Endpoint Engineering Lead | 90 minutes from threshold breach |

### Exact Intune rollback actions

For the impacted ring only (or all active rings if broad trigger):

1. Stop forward rollout:
- Remove FinBridge Connect v3.1 Required assignment from current and pending rollout groups.

2. Revert app version:
- Add FinBridge Connect v3.0 as Required to the same impacted device groups.

3. Remove unstable version from impacted endpoints:
- Add FinBridge Connect v3.1 as Uninstall assignment for impacted groups.
- Exclude dedicated exception group only if incident command approves temporary dual-version hold for diagnostics.

4. Protect unaffected cohorts:
- Keep unaffected completed ring groups unchanged unless trigger is business-critical or cross-ring systemic.

5. Communication and verification SLA:
- Service desk advisory in 30 minutes.
- Finance stakeholder update in 30 minutes if Finance affected.
- Intune rollback verification checkpoint at +2 hours and +8 hours.

### Ring isolation action for 4GB RAM cohort

- Move DWP-Win11-4GB-AtRisk devices to exclusion group: DWP-FinBridge-v31-Hold-4GB.
- Keep non-4GB ring progression active if non-at-risk metrics remain within thresholds.
- Require a successful remediation mini-pilot (minimum 30 at-risk devices, at least 48 hours, 95% Installed, less than 5 incidents per 100 devices) before re-entry.

## 4. FINANCE DEADLINE RESOLUTION

### Option A: Compress pilot so Finance enters Ring 2 by end of Week 1

Minimum safe pilot duration:

- 48 hours absolute minimum with at least 2 check-in cycles and one business-day usage window.

Risk introduced:

- Lower probability of catching delayed detection-loop defects or model-specific failures before Finance exposure.

Compensating control:

- Enforce an expanded pilot composition (higher share of finance workflows and 4GB devices), plus mandatory twice-daily telemetry review and pre-approved rollback runbook.

### Option B: Finance as separate Ring 0 before main pilot

Ring 0 structure:

- Size: 500 finance users/devices (deadline-critical cohort)
- Start: Day 1 morning
- Duration: 3 business days minimum with daily checkpoints
- Assignment: dedicated static device-based Required group (DWP-Finance-FinBridge-v31-Ring0)

Ring 0 advance conditions:

- At least 97.0% Installed within 72 hours
- No more than 2.5% Failed
- No Sev1 finance process outage
- No more than 5 tickets per 100 devices in first 72 hours

Ring 0 rollback plan:

- If any rollback trigger in Section 3 is met for Finance, remove v3.1 Required from Ring 0, assign v3.1 Uninstall to Ring 0, assign v3.0 Required to Ring 0 within 30 minutes of decision.

### Recommendation (single decision)

Recommend Option B.

Justification:

- It meets the fixed Finance end-of-week-1 deadline without weakening risk controls for the other 9,500 endpoints.
- It keeps the global pilot quality bar intact (Ring 1 remains a proper technical pilot instead of an overly compressed checkpoint).
- It isolates business-critical urgency to a bounded cohort with explicit rollback mechanics, reducing blast radius if v3.1 has edge-case behavior on older hardware.
- It preserves schedule feasibility for full fleet completion inside 3 weeks by running Finance priority deployment in parallel with controlled main-ring readiness activities.

