# L2: Legal Floor 6 Copilot Unexpected Client-Matter Content

**Version:** 1.0  
**Date:** 2026-08-14  
**Status:** Draft  
**Source:** `floor6-copilot-access-runbook.md`

## Incident classification

Treat a report that Copilot displayed client-matter content the user states they could never access as a potential confidentiality and access-control incident. The current source record confirms one paralegal report and a Security/Data Governance investigation, but does not provide the confirmed access path, scope, or remediation. Do not convert triage hypotheses into a root cause.

## L2 handling boundaries

L2 may preserve and route evidence through the approved process. L2 must not:

- Reproduce the Copilot response or ask the user to repeat the prompt.
- Change permissions or remove group membership.
- Alter DMS or SharePoint access.
- Delete Copilot history.
- Apply an unapproved technical fix.
- State that access was appropriate, inappropriate, removed, or contained without the investigation owner's confirmation.
- Attribute the issue to the Friday Document Manager deployment, group membership, inheritance, sharing, Copilot, SharePoint, DMS, or indexing without an approved finding.

## Required evidence

Create or update the security/data-governance incident and capture, through the approved incident evidence process:

- Incident/case reference.
- Affected user identity and device name.
- Approximate report date/time.
- Matter identifier.
- Exact Copilot prompt and response.
- Any missing details, explicitly marked `to confirm`.

Keep matter-related evidence out of ordinary Service Desk notes and unapproved channels. Preserve the original report without paraphrasing away the user's statement.

## Procedure

1. Confirm the report is logged as a security/data-governance investigation.
   **Expected result:** An accountable case exists and its reference is linked to the Service Desk ticket.
2. Preserve the original report and collect the required evidence through the approved process.
   **Expected result:** A traceable evidence package exists without additional reproduction or access activity.
3. Route the case to Security, Data Governance, Microsoft 365/Copilot, and DMS permission owners.
   **Expected result:** All responsible owners have the case reference and evidence needed for investigation.
4. Tell the user the matter is under investigation and that root cause and resolution are not confirmed.
   **Expected result:** User communication is accurate and does not imply a finding.
5. Keep the ticket open and link approved investigation updates.
   **Expected result:** Ownership and communication history remain auditable.
6. Wait for the authorized owner to provide the exact finding, scope, approved remediation, authorization, executor, completion time, and verification result.
   **Expected result:** Any technical action is tied to an approved access-path determination.
7. If an approved containment/remediation action is supplied, record its approval and execute only that action.
   **Expected result:** The change is limited to the confirmed scope and can be audited.

## Verification and closure

Before closure, confirm all of the following in the case record:

- Exact Security/Data Governance finding and evidence references.
- Confirmed users, matters/content, and time window.
- Exact remediation action, approver, executor, authorization, and completion time.
- Verification that the affected user's effective access matches the approved authorization model.
- Where approved, verification that the identified access path no longer produces unintended content exposure without creating unauthorized test access.
- Completion of required security, legal, privacy, retention, notification, and user-communication actions.
- Investigation-owner approval to close the Service Desk ticket.

## Rollback of approved remediation

There is no generic rollback because the source record does not identify the access path or remediation. If an approved remediation causes unintended access loss or wider impact:

1. Stop further execution.
   **Expected result:** No additional users, matters, or systems are changed.
2. Notify Security/Data Governance and the named control owner with the action reference and observed impact.
   **Expected result:** The authorized owner can direct the response.
3. Restore the last approved authorization state only as directed by Security/Data Governance and the service owner.
   **Expected result:** The documented approved model is restored without guessed permission changes.
4. Record the rollback action, approval, executor, time, scope, and evidence.
   **Expected result:** Original remediation and rollback are distinguishable and auditable.
5. Re-verify effective access and exposure scope.
   **Expected result:** The resulting state is confirmed before closure or further change.

## Communications

A floor-wide message is not appropriate while one report is confirmed and the investigation is incomplete. Reassess targeted or floor-wide communication only when Security/Data Governance confirms scope, required user action, and approved wording. If the investigation confirms no relationship to the Friday deployment, document that determination and do not create deployment-specific corrective work.
