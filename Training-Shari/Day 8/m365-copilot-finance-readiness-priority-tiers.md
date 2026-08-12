# Microsoft 365 Copilot Readiness Priority Tiers
## Finance Department | Approximately 200 users

**Decision rule:** Do not begin the Finance Copilot pilot until every MUST item is complete, exceptions are documented, and the Finance data owner and security or compliance owner have signed off.

## MUST complete before rollout (blocking)

### 1. Complete the permissions and oversharing audit

- [ ] Inventory Finance SharePoint sites, Teams-connected sites, OneDrive locations, libraries, and high-risk folders.
- [ ] Review the 2019 inherited permissions and confirm access is still appropriate for current job duties.
- [ ] Remove stale users, leavers, former project members, unnecessary guests, and inappropriate broad groups.
- [ ] Review company-wide, anonymous, public, and external sharing links.
- [ ] Review access to payroll, board packs, M&A documents, and client financial data.
- [ ] Check OneDrive sharing and sensitive files copied to weaker-permission locations.
- [ ] Record exceptions with an owner, expiry date, and remediation date.
- [ ] Obtain Finance data owner and security or compliance sign-off.

**Why this is blocking for Finance:** Copilot can help users find and summarise content they already have permission to access. It does not repair incorrect permissions. A permission mistake inherited from 2019 could therefore expose sensitive payroll, board, M&A, or client information to a wider audience through natural-language search and summaries. Licensing is simpler to verify and a supported client is necessary, but neither prevents an existing oversharing problem from becoming easier to discover. The risk is a data exposure risk, not merely a setup inconvenience, so the audit must come first.

### 2. Confirm identity and MFA controls

- [ ] Confirm each pilot user has one active work identity and no stale duplicate account.
- [ ] Require MFA through the approved Conditional Access policy.
- [ ] Test sign-in, MFA prompts, recovery, and approved Conditional Access exceptions.
- [ ] Confirm privileged administrators use separate accounts and the required strong authentication.

### 3. Confirm the minimum licensing and tenant gate

- [ ] Validate that the intended users have eligible Microsoft 365 licensing. The current E5 licensing is the base prerequisite.
- [ ] Confirm the Microsoft 365 Copilot add-on is available and assign it only to the approved pilot group after the permissions sign-off.
- [ ] Confirm the pilot group has an owner and contains only approved Finance users.

## SHOULD complete before rollout (high risk if skipped)

### Microsoft 365 Apps and device readiness

- [ ] Confirm pilot devices use a supported Microsoft 365 Apps build and update channel.
- [ ] Confirm Word, Excel, PowerPoint, Outlook, and OneNote are supported Microsoft 365 Apps installations.
- [ ] Confirm apps are signed in with the work account and receive approved updates.
- [ ] Bring devices behind on updates to the supported build.
- [ ] Confirm Windows and device-management requirements are met.
- [ ] Test Copilot in the relevant desktop and web apps.

### Sensitivity labels and data protection

- [ ] Confirm Finance sensitivity labels are published and available in supported apps.
- [ ] Agree labels and handling rules for payroll, board packs, M&A, and client financial data.
- [ ] Test labels, encryption, access restrictions, and sharing controls.
- [ ] Identify important files with missing or outdated labels and assign remediation owners.
- [ ] Define data types or locations excluded from the pilot and apply the approved controls.

### Pilot controls

- [ ] Document pilot size, success measures, review date, and removal process.
- [ ] Confirm joiner, mover, and leaver processes remove Copilot access promptly.
- [ ] Confirm no unresolved high-severity access or data-protection issue remains before expansion.

## CAN complete during or after rollout (lower risk)

### Communications and enablement

- [ ] Send Finance-specific guidance on suitable Copilot uses and prohibited handling of confidential information.
- [ ] Explain that Copilot follows existing permissions and cannot correct SharePoint access mistakes.
- [ ] Provide safe examples using non-sensitive sample data.
- [ ] Deliver a short demonstration and prompt guidance.
- [ ] Publish service desk guidance for sign-in, missing Copilot, access concerns, unexpected content, and suspected exposure.
- [ ] Name the Finance business owner, service desk contact, and technical escalation owner.

### Post-pilot learning and controlled expansion

- [ ] Ask pilot users for feedback after the first week.
- [ ] Review pilot results against the agreed success measures.
- [ ] Recheck access and sharing exceptions as remediation work completes.
- [ ] Expand in controlled groups only after Finance, security, and service owners approve the next phase.

> Communications should be prepared before the pilot begins, but they do not replace the MUST controls. A well-informed user cannot prevent Copilot from surfacing content that is already shared too broadly.
