# RCA: Legal Floor 6 Login and Performance Incident

## Incident Summary

On Monday morning, Legal Floor 6 users reported inability to log in or unusually slow logins. Poor workstation performance was also reported in the wider Floor 6 incident scope. At least approximately 12 users were reported affected; the exact count, affected users, and affected devices are **to confirm**.

A new document management application was deployed to Floor 6 on the preceding Friday afternoon. During triage, deployment-related endpoint impact was ranked as the leading hypothesis because it was the only recorded change explicitly targeted to the affected floor immediately before the reports. This timing alone did not confirm causation.

The suggested resolution was applied and the issue is reported resolved as of **[confirmed time - to confirm]**. The exact action applied, approving authority, execution evidence, and verification result are **to confirm**. The closure verification detail should be recorded as: **[confirmed verification detail - to confirm]**.

## Impact

- **Affected location:** Legal Floor 6.
- **Reported symptoms:** Login failure, prolonged login, and poor workstation performance.
- **Reported scope:** At least approximately 12 users; exact population **to confirm**.
- **Business impact:** Users were unable to work normally or experienced delayed access to their workstations.
- **Incident status:** Resolved, based on the reported completion of the suggested resolution; resolution timestamp and evidence **to confirm**.

## Confirmed Facts and Supporting Evidence

| Evidence area | Confirmed fact | Significance | Evidence still required |
|---|---|---|---|
| Deployment timing | A new document management application was rolled out to Floor 6 on Friday afternoon. | Establishes a relevant change before the incident reports. | Exact package name, version, deployment ID, assignment/collection, device install status, and timestamps: **to confirm**. |
| Incident timing | Login failures and slow logins were reported Monday morning. | Establishes the observed onset/reporting window after the Friday change. | Exact first symptom time per user/device: **to confirm**. |
| User impact | At least approximately 12 Floor 6 users were reported affected. | Establishes a multi-user, floor-scoped incident. | Exact count, user/device list, and unaffected controls: **to confirm**. |
| Symptom pattern | Users reported either login failure or very slow login. Poor workstation performance was reported in the incident scope. | Supports investigation of sign-in dependencies and endpoint resource contention. | Exact error messages, logon phase, CPU/memory/disk measurements, and application process/service behavior: **to confirm**. |
| Hypothesis ranking | Deployment-related endpoint impact was ranked highest during triage. | Justifies investigation of the Friday deployment first. | Causal correlation between deployment component and symptoms: **to confirm**. |
| Alternative causes | Authentication/sign-in service and Windows 11/Intune configuration causes remained credible during triage. | Prevents treating temporal correlation as proof. | Authentication, domain, DNS, Group Policy, profile, Intune, and endpoint comparisons: **to confirm**. |
| Resolution | Suggested resolution was applied and the issue is reported resolved. | Establishes closure status provided for this RCA. | Exact action, execution time, change/incident approval, and validation evidence: **to confirm**. |

## Timeline

| Time | Event | Status |
|---|---|---|
| Friday afternoon | New document management application deployed to Legal Floor 6. | Confirmed at day/time granularity; exact deployment start/end and package details **to confirm**. |
| Monday morning | Floor 6 users report login failures or prolonged login. | Confirmed at day/time granularity; exact first report and individual symptom times **to confirm**. |
| Monday morning | At least approximately 12 users reported affected. | Confirmed as a reported scope; exact count and affected population **to confirm**. |
| During triage | Deployment-related endpoint impact ranked as the leading hypothesis. Authentication and Windows 11/Intune alternatives remained open. | Confirmed. |
| [to confirm] | Suggested resolution applied. | Reported complete; exact technical action, executor, approval, and timestamp **to confirm**. |
| [confirmed time - to confirm] | Incident reported resolved. | Reported complete; record final timestamp. |
| [to confirm] | Verification completed: `[confirmed verification detail - to confirm]`. | Required before final closure evidence is complete. |

## Root Cause Assessment

**Root cause: to confirm.**

The Friday document management deployment was the leading working hypothesis because of its Floor 6 scope and timing. The available record does not contain deployment telemetry, endpoint resource data, sign-in/event logs, or an exact resolution action that demonstrates the deployment caused the login/performance symptoms. Therefore, this RCA must not state that resource contention, a post-install script, a DMS service, or the application itself was the confirmed root cause.

To confirm the root cause, retain and review the following evidence:

- Deployment status and installation timestamps for affected and unaffected Floor 6 devices.
- Relevant Application, System, Security, Group Policy, and Intune Management Extension logs around affected sign-ins.
- Endpoint CPU, memory, disk, process, service, startup, and scheduled-task evidence during the symptom window.
- The exact remediation/rollback/pause action and its execution record.
- Before/after verification showing the symptom present before remediation and absent afterward on identified affected devices.

## 5-Why Analysis

| Why | Answer | Evidence status |
|---|---|---|
| 1. Why could affected Floor 6 users not log in normally? | They reported login failures or unusually slow logins. | Confirmed as reported symptoms; exact failure mechanism **to confirm**. |
| 2. Why did login fail or take longer? | The sign-in dependency or endpoint activity responsible has not been identified. | **To confirm** through event logs and endpoint evidence. |
| 3. Why was a deployment-related endpoint impact ranked first? | A document management application was deployed to the affected Floor 6 population on Friday afternoon, before Monday reports. | Confirmed; timing is correlation, not proof. |
| 4. Why would that deployment affect login/performance? | Possible resource contention, service, script, policy, profile, or installer activity was hypothesized. | **To confirm**; no mechanism is evidenced in the available record. |
| 5. Why did the issue resolve after the suggested action? | The suggested resolution was reported applied and the incident reported resolved. | Exact action, causal link, resolution time, and verification evidence are **to confirm**. |

## Resolution and Verification

**Resolution applied:** `[suggested resolution actually applied - to confirm]`.

**Permissions/change approval:** `[incident/change reference and approver - to confirm]`.

**Completion time:** `[confirmed time - to confirm]`.

**Verification:** `[confirmed verification detail - to confirm]`.

Minimum closure evidence to add:

1. The management-console or command output showing the actual action applied.
2. Affected user/device list with before-and-after sign-in outcome.
3. A statement of whether workstation performance returned to normal, supported by user confirmation or endpoint measurements.
4. Confirmation that the affected deployment ring/collection will not reapply the contributing configuration, if deployment causation is later confirmed.

## Preventive Actions

| Action | Owner | Due date | Success measure |
|---|---|---|---|
| Preserve the deployment record, endpoint evidence, sign-in logs, and resolution evidence for post-incident review. | Incident Manager / Endpoint Engineering: **to confirm** | **To confirm** | Evidence identifies either a confirmed cause or a documented reason causation could not be confirmed. |
| Compare affected devices with unaffected Floor 6 controls for Document Manager version, installation time, sign-in events, resource use, and applied policy. | Endpoint Engineering: **to confirm** | **To confirm** | Comparison result is recorded and reviewed by the incident owner. |
| If deployment causation is confirmed, update the deployment package, detection logic, post-install behavior, or rollout design to prevent recurrence. | Application Owner / Endpoint Engineering: **to confirm** | **To confirm** | Corrected package succeeds in an approved pilot without recurring sign-in or performance symptoms. |
| If deployment causation is not confirmed, create corrective work for the confirmed authentication, policy, profile, Windows 11/Intune, or infrastructure cause. | Responsible service owner: **to confirm** | **To confirm** | Corrective action and verification are recorded in the linked problem record. |
| Require a monitored pilot and an affected/unaffected comparison before future Floor 6 application ring expansion. | Change Manager / Endpoint Engineering: **to confirm** | **To confirm** | Pilot criteria and monitoring results are approved before broader rollout. |

## Closure Criteria

The incident can be fully closed when the following are recorded:

- Confirmed resolution time and the exact technical action applied.
- Confirmed verification detail showing affected users can log in normally and workstation performance is acceptable.
- Exact affected scope and any remaining user impact.
- Root cause determination, or a documented statement that root cause remains unconfirmed with an assigned follow-up problem record.
- Evidence of corrective/preventive action ownership and due dates.