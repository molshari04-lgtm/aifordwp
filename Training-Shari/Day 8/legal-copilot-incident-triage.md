# Legal Copilot Incident Triage

## Ticket 1: Paralegal cannot summarise SharePoint NDA

**Scenario:** The paralegal asked Copilot to summarise a client NDA and received "I don't have access to that content." She has never opened the folder directly.

**Likely cause, ranked:**
1. Permissions/access boundary
2. Sensitivity label restriction
3. Guest/external sharing limitation
4. Data indexing lag
5. License/client prerequisite issue
6. Genuine Copilot fault

**Fastest check:** Have the paralegal open the exact NDA and parent folder directly in SharePoint, then retry using the file link.

**Is this actually a Copilot bug?** **No.** Meeting knowledge does not grant SharePoint access; direct permissions, client sharing, and sensitivity controls must be checked first.

## Ticket 2: New associate cannot find case emails

**Scenario:** An associate who started this week cannot get Copilot in Outlook to find the case emails needed for context.

**Likely cause, ranked:**
1. License/client prerequisite issue
2. Data indexing lag
3. Permissions/access boundary
4. Sensitivity label restriction
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Confirm the associate can see the required emails in the new mailbox and verify that the Copilot license, mailbox, and required group memberships are provisioned.

**Is this actually a Copilot bug?** **No.** A new starter is more likely to have incomplete licensing, mailbox provisioning, access, or indexing than a Copilot defect.

## Ticket 3: Partner sees an unrelated draft settlement

**Scenario:** Copilot surfaced and summarised a draft settlement from a matter the partner is not assigned to. The partner did not know the folder was visible.

**Likely cause, ranked:**
1. Permissions/access boundary
2. Sensitivity label restriction
3. Guest/external sharing limitation
4. Data indexing lag
5. License/client prerequisite issue
6. Genuine Copilot fault

**Fastest check:** Review the partner's effective permissions on the settlement folder, including inherited access, group membership, sharing links, and site membership.

**Is this actually a Copilot bug?** **Unclear.** Treat this first as a potential matter-confidentiality and access-governance incident; Copilot may be exposing content already available to the partner's identity. Escalate if effective permissions do not explain the exposure.

## Ticket 4: Legal team loses Copilot access

**Scenario:** All 40 Legal team members suddenly lost Copilot access this morning after it worked throughout last week.

**Likely cause, ranked:**
1. License/client prerequisite issue
2. Permissions/access boundary
3. Sensitivity label restriction
4. Guest/external sharing limitation
5. Data indexing lag
6. Genuine Copilot fault

**Fastest check:** Test a representative Legal user and a non-Legal user, then check Microsoft 365 service health and recent license, group, identity-policy, or tenant changes.

**Is this actually a Copilot bug?** **Unclear.** Synchronized team-wide impact points first to a common license, prerequisite, or access boundary; investigate a genuine Copilot fault only after those checks.

## Ticket 5: Generic answers about contract templates

**Scenario:** A contract specialist receives vague answers about clauses in the contract templates library, as if Copilot is not reading the documents.

**Likely cause, ranked:**
1. Data indexing lag
2. Permissions/access boundary
3. Sensitivity label restriction
4. License/client prerequisite issue
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Open one known template directly, confirm access, and ask Copilot a question that cites the exact file and a distinctive clause.

**Is this actually a Copilot bug?** **Unclear.** If the exact accessible file still produces generic answers after indexing completes, investigate Copilot retrieval; otherwise check access, indexing, sensitivity, and licensing first.
