# Copilot Support Ticket Triage

## Ticket 1
**Likely cause, ranked:**
1. Permissions/access boundary
2. Data indexing lag
3. Sensitivity label restriction
4. License/client prerequisite issue
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Confirm the Finance lead has direct access to the Q3 board pack and can open it from the same SharePoint location.

**Is this actually a Copilot bug?** **No.** Seeing a file does not guarantee Copilot can use its content; permissions or labels may restrict processing.

## Ticket 2
**Likely cause, ranked:**
1. Data indexing lag
2. License/client prerequisite issue
3. Permissions/access boundary
4. Sensitivity label restriction
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Confirm that the recent emails are visible in Outlook in the user's new work account.

**Is this actually a Copilot bug?** **No.** The user started yesterday, so mailbox indexing or access provisioning is the most likely explanation.

## Ticket 3
**Likely cause, ranked:**
1. Sensitivity label restriction
2. Permissions/access boundary
3. License/client prerequisite issue
4. Data indexing lag
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Confirm that the HR manager can open the exact spreadsheet directly.

**Is this actually a Copilot bug?** **No.** The message indicates that access or sensitivity controls are working as designed.

## Ticket 4
**Likely cause, ranked:**
1. Guest/external sharing limitation
2. Permissions/access boundary
3. Data indexing lag
4. Sensitivity label restriction
5. License/client prerequisite issue
6. Genuine Copilot fault

**Fastest check:** Confirm whether the contract opens directly through the guest link while signed in as the Sales rep.

**Is this actually a Copilot bug?** **No.** Content shared from another organisation may not be available to Copilot in the same way as internal content.

## Ticket 5
**Likely cause, ranked:**
1. License/client prerequisite issue
2. Permissions/access boundary
3. Data indexing lag
4. Sensitivity label restriction
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Check whether the issue also affects a user outside the Finance team.

**Is this actually a Copilot bug?** **Unclear.** A whole-team outage suggests a shared licensing, client, or access change; a Copilot fault should be considered only after those checks.

## Ticket 6
**Likely cause, ranked:**
1. Permissions/access boundary
2. Sensitivity label restriction
3. Data indexing lag
4. License/client prerequisite issue
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Review the manager's access to the folder and file directly.

**Is this actually a Copilot bug?** **No.** Copilot surfaced content the manager already had access to; the unexpected access is a permissions review issue.

## Ticket 7
**Likely cause, ranked:**
1. Permissions/access boundary
2. Data indexing lag
3. License/client prerequisite issue
4. Sensitivity label restriction
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Ask Copilot to summarise one known SharePoint file the analyst can open directly.

**Is this actually a Copilot bug?** **Unclear.** If one accessible file also cannot be found after indexing and access checks pass, further Copilot investigation is justified.

## Ticket 8
**Likely cause, ranked:**
1. Permissions/access boundary
2. License/client prerequisite issue
3. Data indexing lag
4. Sensitivity label restriction
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Confirm the assistant has direct permission to the shared mailbox calendar, not only delegated mailbox access.

**Is this actually a Copilot bug?** **No.** Managing a calendar does not necessarily grant Copilot the required access boundary to use it.

## Ticket 9
**Scenario:** A paralegal asked Copilot to summarise a client NDA in SharePoint and received "I don't have access to that content." The file is in a folder she has never opened before.

**Likely cause, ranked:**
1. Permissions/access boundary
2. Data indexing lag
3. Sensitivity label restriction
4. Guest/external sharing limitation
5. License/client prerequisite issue
6. Genuine Copilot fault

**Fastest check:** Ask the paralegal to open the exact NDA and its parent folder directly in SharePoint, then retry the prompt using the file link.

**Is this actually a Copilot bug?** **Probably no.** Hearing about content in a meeting does not grant access to it; direct access and any client-sharing or sensitivity controls must be checked first.

## Ticket 10
**Scenario:** A new associate, who started this week, cannot get Copilot in Outlook to find the case emails needed for context.

**Likely cause, ranked:**
1. License/client prerequisite issue
2. Data indexing lag
3. Permissions/access boundary
4. Mailbox or account provisioning delay
5. Sensitivity label restriction
6. Genuine Copilot fault

**Fastest check:** Confirm the associate can see the required case emails in the new mailbox and check that the Copilot license and mailbox provisioning completed successfully.

**Is this actually a Copilot bug?** **Probably no.** A new starter is more likely to have an incomplete license, mailbox, group, or search-indexing setup than a Copilot defect.

## Ticket 11
**Scenario:** A partner received a Copilot summary of a draft settlement from a matter they are not assigned to and did not know they could see the folder.

**Likely cause, ranked:**
1. Permissions/access boundary
2. Inherited SharePoint or Teams membership
3. Sensitivity label or sharing configuration
4. Data indexing lag
5. License/client prerequisite issue
6. Genuine Copilot fault

**Fastest check:** Review the partner's effective permissions on the settlement folder, including inherited access, group membership, sharing links, and site membership.

**Is this actually a Copilot bug?** **No.** Copilot is exposing content available to the partner's identity; treat this as a potential matter-confidentiality and permissions incident.

## Ticket 12
**Scenario:** All 40 people on the Legal team suddenly lost Copilot access this morning after it worked throughout last week.

**Likely cause, ranked:**
1. License assignment or subscription change
2. Tenant or service outage
3. Conditional Access or identity policy change
4. Group membership or provisioning failure
5. Client update or configuration issue
6. Genuine isolated Copilot fault

**Fastest check:** Test a representative Legal user and a non-Legal user, then check Microsoft 365 service health and recent license, group, identity-policy, or tenant configuration changes.

**Is this actually a Copilot bug?** **Unclear, but treat as a major shared-service incident.** The synchronized team-wide impact points to a common entitlement, policy, tenant, or service-health cause rather than individual user error.

## Ticket 13
**Scenario:** A contract specialist gets vague, generic answers about clauses in the contract templates library, as if Copilot is not reading the documents.

**Likely cause, ranked:**
1. Data indexing or search retrieval failure
2. Permissions/access boundary
3. Sensitivity label restriction
4. Prompt or document-reference ambiguity
5. License/client prerequisite issue
6. Genuine Copilot fault

**Fastest check:** Open one known template directly, confirm the specialist has access, and ask Copilot a question that cites that exact file and a distinctive clause.

**Is this actually a Copilot bug?** **Unclear.** If the exact accessible file still produces generic answers after indexing has completed, Copilot retrieval or grounding should be investigated; otherwise the issue is likely access, indexing, or prompt scope.
