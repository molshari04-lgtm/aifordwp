# RCA: Legal Floor 6 Missing Desktop Shortcuts

## Incident Summary

On Monday morning, one Legal Floor 6 user reported that desktop shortcuts had vanished. The user’s name, device name, the specific missing shortcuts, and whether any other users or devices were affected are **to confirm**.

Legal Floor 6 was recently migrated to Windows 11 and enrolled in Intune. A new document management application was deployed to the floor on the preceding Friday afternoon. During triage, a deployment-related shortcut or desktop-configuration change was ranked as the leading hypothesis because it was the recorded change immediately before the report. This timing did not confirm that the deployment removed or altered shortcuts.

The suggested resolution was applied and the issue is reported resolved as of **[confirmed time - to confirm]**. The exact action applied, approval, execution evidence, and verification result are **to confirm**. The closure verification detail should be recorded as: **[confirmed verification detail - to confirm]**.

## Impact

- **Affected location:** Legal Floor 6.
- **Reported user impact:** One user reported missing desktop shortcuts.
- **Affected scope:** One confirmed report; whether other users/devices were affected is **to confirm**.
- **Business impact:** The missing shortcuts may have disrupted access to routine applications or files; actual business impact is **to confirm**.
- **Incident status:** Resolved, based on the reported completion of the suggested resolution; closure time and evidence are **to confirm**.

## Confirmed Facts and Supporting Evidence

| Evidence area | Confirmed fact | Significance | Evidence still required |
|---|---|---|---|
| User report | One Legal Floor 6 user reported that desktop shortcuts vanished Monday morning. | Establishes the reported symptom and initial scope. | User/device identity, exact report time, missing shortcut inventory, screenshots, and confirmation that shortcuts were previously present: **to confirm**. |
| Floor context | Legal Floor 6 has 45 people and was recently migrated to Windows 11 and enrolled in Intune. | Identifies relevant management and operating-system context. | Whether this user/device differs from other Floor 6 devices in build, policy, profile, or Intune status: **to confirm**. |
| Deployment timing | A new document management application was deployed to Floor 6 on Friday afternoon. | Establishes a relevant change before the report. | Exact package/version, deployment ID, device assignment, install status, and deployment timestamps: **to confirm**. |
| Hypothesis ranking | Deployment-related shortcut/desktop change was ranked as the leading hypothesis. | Justifies investigation of package and deployment behavior. | Evidence that the post-install script created, removed, or changed shortcuts: **to confirm**. |
| Alternative explanations | User profile, desktop-folder location, Intune policy, OneDrive, and folder-redirection explanations remained possible. | Prevents temporal correlation from being treated as root cause. | Profile state, folder paths, Group Policy/Intune configuration, OneDrive status, and desktop folder contents: **to confirm**. |
| Resolution | Suggested resolution was applied and the issue is reported resolved. | Establishes reported closure status. | Exact resolution, executor, approval, time, and before/after validation: **to confirm**. |

## Timeline

| Time | Event | Status |
|---|---|---|
| Friday afternoon | New document management application deployed to Legal Floor 6. | Confirmed at day/time granularity; exact package and deployment timing **to confirm**. |
| Monday morning | One Legal Floor 6 user reported vanished desktop shortcuts. | Confirmed at day/time granularity; exact report time **to confirm**. |
| During triage | Deployment-related shortcut/desktop change was ranked first. Profile, desktop location, and Intune policy explanations remained open. | Confirmed. |
| [to confirm] | Suggested resolution applied. | Reported complete; exact technical action, executor, approval, and timestamp **to confirm**. |
| [confirmed time - to confirm] | Issue reported resolved. | Record final closure time. |
| [to confirm] | Verification completed: `[confirmed verification detail - to confirm]`. | Required to complete closure evidence. |

## Root Cause Assessment

**Root cause: to confirm.**

The Friday document management deployment was the highest-ranked working hypothesis due to the Floor 6 deployment scope and timing. The available record does not establish that a post-install script removed or altered shortcuts, that the change affected all user profiles, or that the deployment was the cause of the reported symptom. It also does not rule out an abnormal user profile, a changed desktop location, an Intune-delivered configuration, folder redirection, or OneDrive Known Folder Move.

Before confirming root cause, retain and review:

- The affected user’s Desktop, Public Desktop, and any redirected/OneDrive Desktop folder contents and timestamps.
- The exact list of missing shortcuts, their expected target paths, and whether they were user-created, application-created, or centrally deployed.
- The affected device’s user-profile state, temporary-profile indicators, and sign-in/profile events.
- Intune/SCCM deployment status, package content, install/uninstall/post-install commands, and associated deployment logs.
- Group Policy, Intune policy, folder-redirection, and OneDrive Known Folder Move state.
- An unaffected Floor 6 device/user comparison and the exact remediation result.

## 5-Why Analysis

| Why | Answer | Evidence status |
|---|---|---|
| 1. Why could the affected user not use the expected desktop shortcuts? | The user reported that their desktop shortcuts had vanished. | Confirmed as a reported symptom; exact shortcut list **to confirm**. |
| 2. Why were the shortcuts absent from the user’s desktop experience? | The specific condition is not identified. They may have been removed, moved, hidden, redirected, or unavailable through a profile issue. | **To confirm** through desktop-path, shortcut, and profile evidence. |
| 3. Why was the deployment-related theory ranked first? | A new document management application was deployed to the affected floor on Friday afternoon before the Monday report. | Confirmed; timing is correlation, not proof. |
| 4. Why would the deployment change shortcuts? | A post-install script or deployment configuration might create, remove, or change shortcut behavior. | **To confirm**; package/script content and execution evidence are not recorded. |
| 5. Why did the issue resolve after the suggested action? | The suggested resolution was reported applied and the issue reported resolved. | Exact action, causal link, resolution time, and verification evidence are **to confirm**. |

## Resolution and Verification

**Resolution applied:** `[suggested resolution actually applied - to confirm]`.

**Permissions/change approval:** `[incident/change reference and approver - to confirm]`.

**Completion time:** `[confirmed time - to confirm]`.

**Verification:** `[confirmed verification detail - to confirm]`.

Minimum closure evidence to add:

1. The management-console output, remediation log, or command output showing the exact action applied.
2. The shortcut name(s), expected target path(s), and evidence that they were restored to the correct user, public, or redirected desktop location.
3. Affected-user confirmation that the restored shortcuts are visible and open the intended application or location.
4. A recheck after sign-in or policy processing to confirm the shortcuts do not disappear again.
5. Confirmation that no other Floor 6 users are affected, or an updated incident scope if additional users are found.

## Preventive Actions

| Action | Owner | Due date | Success measure |
|---|---|---|---|
| Preserve the affected device’s shortcut, profile, deployment, and remediation evidence for post-incident review. | Incident Manager / Endpoint Engineering: **to confirm** | **To confirm** | Evidence either confirms the cause or records why it remains unconfirmed. |
| Review the Document Manager package and post-install/uninstall behavior for shortcut or desktop-folder changes. | Application Owner / Endpoint Engineering: **to confirm** | **To confirm** | Package behavior is documented and no unapproved shortcut changes remain. |
| Compare an affected user/device with an unaffected Floor 6 user/device for desktop paths, profile state, OneDrive/folder-redirection state, policy, and deployment version. | Endpoint Engineering: **to confirm** | **To confirm** | Comparison result is attached to the incident/problem record. |
| If deployment causation is confirmed, correct the package and test shortcut behavior in an approved pilot before another Floor 6 rollout. | Application Owner / Change Manager: **to confirm** | **To confirm** | Pilot confirms expected shortcuts persist through sign-in and deployment completion. |
| If deployment causation is not confirmed, assign corrective work to the confirmed profile, policy, folder-redirection, OneDrive, or Windows 11/Intune owner. | Responsible service owner: **to confirm** | **To confirm** | Corrective action and validation are recorded in a linked problem record. |

## Closure Criteria

The incident can be fully closed when the following are recorded:

- Confirmed resolution time and exact action applied.
- Confirmed verification showing the affected user can see and use the expected shortcuts.
- Confirmed shortcut scope, including whether additional Floor 6 users/devices were affected.
- Root cause determination, or a documented statement that cause remains unconfirmed with an assigned follow-up problem record.
- Named owners and due dates for corrective/preventive actions.