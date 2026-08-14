# Runbook: Legal Floor 6 Copilot Client-Matter Access Report

**Version:** 1.0  
**Date:** 2026-08-14  
**Status:** Draft  
**Source:** `floor6-copilot-access-issue-response.md` and `floor6-copilot-access-rca.md`

## 1. Prerequisites

- Treat every report of unexpected client-matter content as a potential confidentiality and access-control incident until Security/Data Governance determines otherwise.
- Obtain or create the approved security/data-governance incident record and case reference. The reference is currently to confirm.
- Use the approved incident evidence process for all matter-related information. Do not place client content in ordinary Service Desk notes or unapproved channels.
- Confirm the responsible Security, Data Governance, Microsoft 365/Copilot, and DMS permission owners are identified and available for routing.
- Capture the reporting user identity, device name, approximate report time, matter identifier, and exact Copilot prompt/response only through the approved evidence process. Mark missing values to confirm.
- Do not reproduce the Copilot result, change permissions, remove group membership, alter DMS or SharePoint access, delete Copilot history, or apply a technical fix unless the authorized investigation owner explicitly approves that action.
- Do not infer a cause from the Friday Document Manager deployment, group membership, inherited permissions, sharing, Copilot, SharePoint, DMS, or indexing. These remain unconfirmed until the investigation owner provides the finding.

## 2. Procedure

1. Open or update the security/data-governance incident record and record the incident/case reference.
   **Expected result:** The report is linked to an accountable investigation record; the reference is available to all authorized responders.
2. Preserve the original report exactly as received.
   **Expected result:** The original user statement and report context remain intact and are not altered by troubleshooting.
3. Through the approved evidence process, record the affected user's identity, device name, approximate date/time, matter identifier, and exact Copilot prompt and response.
   **Expected result:** The investigation has a traceable evidence package, with unknown fields explicitly marked to confirm.
4. Do not attempt to reproduce the Copilot response or ask the user to repeat the prompt.
   **Expected result:** No additional access event, matter exposure, or contaminated evidence is created by Service Desk activity.
5. Route the case to Security, Data Governance, Microsoft 365/Copilot, and DMS permission owners.
   **Expected result:** Each responsible owner receives the case reference and the approved evidence package.
6. Tell the reporting user that the matter is under investigation and that no root cause or resolution has been confirmed.
   **Expected result:** The user receives accurate, approved communication without an unsupported claim that access was appropriate, inappropriate, removed, or contained.
7. Keep the Service Desk ticket open, link the security/data-governance case, and record approved updates only.
   **Expected result:** Incident ownership, communication history, and escalation status remain auditable.
8. Wait for Security/Data Governance to provide the exact finding, confirmed scope, approved remediation, authorization, executor, completion time, and verification result before recording closure or applying a technical change.
   **Expected result:** Any action taken is based on an approved finding rather than a triage hypothesis.
9. If the investigation owner approves containment or remediation, record the exact action and approval before execution, then execute only that approved action.
   **Expected result:** The action is authorized, attributable, and limited to the confirmed access path and scope.

## 3. Verification

1. Confirm the case contains the exact approved Security/Data Governance finding and evidence references.
   **Expected result:** The root-cause and access-path fields no longer rely on placeholders or hypotheses.
2. Confirm the affected scope, including users, matters/content, and applicable time window.
   **Expected result:** The incident record states the approved impact determination.
3. Confirm the exact remediation action, approver, executor, authorization, and completion time.
   **Expected result:** The recorded action matches what was actually approved and performed.
4. Confirm Security/Data Governance verified that the affected user's effective access matches the approved authorization model.
   **Expected result:** The access outcome is supported by authorized evidence.
5. Where approved and appropriate, confirm that the identified access path no longer produces unintended content exposure.
   **Expected result:** The remediation is validated without creating unauthorized test access.
6. Confirm required security, legal, privacy, retention, notification, and user-communication actions are complete.
   **Expected result:** Closure obligations are documented by their owners.
7. Close the Service Desk incident only after the investigation owner approves closure.
   **Expected result:** The ticket links the final finding, remediation, verification, scope decision, and preventive actions.

## 4. Rollback

Rollback applies only to an approved remediation or containment action supplied by Security/Data Governance. There is no generic rollback because the source record does not identify the access path or remediation.

1. Stop further execution of the approved remediation or containment action if it causes unintended access loss, wider impact, or another approved rollback trigger.
   **Expected result:** No additional users, matters, or systems are changed by the failing action.
2. Notify Security/Data Governance and the named control owner, preserving the action reference and observed impact.
   **Expected result:** The investigation owner has immediate decision authority and an auditable record of the rollback trigger.
3. Restore the last approved authorization state only as directed by Security/Data Governance and the relevant service owner.
   **Expected result:** Access is restored to the documented approved model without guessing at group, inheritance, sharing, DMS, SharePoint, or Copilot settings.
4. Record the exact rollback action, approver, executor, time, affected scope, and verification evidence.
   **Expected result:** The incident record distinguishes the original remediation from its rollback and supports follow-up review.
5. Re-verify effective access and approved exposure scope before resuming or closing the incident.
   **Expected result:** The resulting state is confirmed by the authorized investigation owners.

## 5. Communication and safety notes

- A floor-wide message is not appropriate while one report is confirmed and the investigation is incomplete.
- Reassess targeted or floor-wide communication only after Security/Data Governance confirms scope, required user action, and approved wording.
- Do not state that the Friday Document Manager deployment caused the report unless Security/Data Governance confirms that relationship.
- Do not apply deployment-specific corrective work if the investigation confirms no relationship to that deployment.
