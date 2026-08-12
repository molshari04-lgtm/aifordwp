# Microsoft 365 Copilot Readiness Checklist
## Finance Department | Approximately 200 users

**Data sensitivity:** High
**Key data:** Payroll, board packs, M&A documents, and client financial data
**Current state:** Microsoft 365 E5 is assigned; Copilot add-on is not yet assigned. SharePoint permissions were inherited from a 2019 migration and have not been fully audited.

> **Gate:** Do not assign Copilot licenses to Finance users until the Priority 1 permissions and oversharing checks are complete, exceptions are documented, and the Finance data owner signs off.

## Priority 1: Permissions and oversharing gate

- [ ] Create an inventory of Finance SharePoint sites, Teams-connected sites, OneDrive locations, document libraries, and high-risk folders.
- [ ] Record each location's owner, business purpose, sensitivity, membership, and external-sharing setting.
- [ ] Review all access inherited from the 2019 migration. Do not assume inherited access is still appropriate.
- [ ] Confirm access is based on current job duties and least privilege.
- [ ] Review broad groups, nested groups, "Everyone except external users," company-wide links, and anonymous or public links.
- [ ] Find and remove stale users, leavers, contractors, former project members, and unnecessary guests.
- [ ] Review external sharing and guest access for payroll, board, M&A, and client financial data.
- [ ] Replace broad sharing links with named-user or approved-group access where appropriate.
- [ ] Check whether sensitive files are copied into locations with weaker permissions.
- [ ] Review SharePoint site and Teams membership with each Finance data owner.
- [ ] Check OneDrive sharing links and shared folders for sensitive Finance content.
- [ ] Confirm access reviews, expiration settings, and alerts are enabled where supported.
- [ ] Record every exception, its business owner, expiry date, and remediation date.
- [ ] Obtain written sign-off from the Finance data owner and security or compliance owner.

## Priority 2: Licensing and tenant prerequisites

- [ ] Confirm all intended users have an eligible Microsoft 365 license. The current E5 licenses meet the base licensing requirement, subject to tenant validation.
- [ ] Purchase or assign the Microsoft 365 Copilot add-on only to the approved pilot users first.
- [ ] Confirm Copilot is available in the tenant and that service plans are not blocked by group-based licensing or policy.
- [ ] Confirm the pilot group contains only approved Finance users and has a named owner.
- [ ] Document the pilot size, success measures, review date, and process for removing access.

## Priority 3: Microsoft 365 Apps client readiness

- [ ] Confirm pilot users run a supported Microsoft 365 Apps build and update channel for Copilot.
- [ ] Confirm Word, Excel, PowerPoint, Outlook, and OneNote are installed from Microsoft 365 Apps, not unsupported perpetual or volume-only builds.
- [ ] Confirm apps are signed in with the user's work account and receive updates from the approved update channel.
- [ ] Bring devices that are behind on updates to the organisation's supported build before the pilot.
- [ ] Confirm Windows devices meet the organisation's supported operating system and device-management requirements.
- [ ] Test Copilot availability in the relevant desktop and web apps for pilot users.

## Priority 4: Identity, access, and MFA readiness

- [ ] Confirm every pilot user has one active work identity and no duplicate or stale account.
- [ ] Confirm MFA is registered and required through the organisation's approved Conditional Access policy.
- [ ] Test sign-in, MFA prompts, password reset, and account recovery for pilot users.
- [ ] Confirm privileged administrators use separate admin accounts and strong phishing-resistant authentication where required.
- [ ] Review Conditional Access exclusions and document any approved exceptions.
- [ ] Confirm device compliance and sign-in risk policies do not unintentionally block approved users.
- [ ] Verify joiner, mover, and leaver processes remove Copilot access promptly.

## Priority 5: Sensitivity labelling and data protection

- [ ] Confirm sensitivity labels are published to Finance users and appear in the supported Microsoft 365 apps.
- [ ] Review labels for Public, Internal, Confidential, and highly restricted Finance information.
- [ ] Confirm payroll, board, M&A, and client financial data have an agreed label and handling rule.
- [ ] Test whether labels, encryption, access restrictions, and sharing controls behave as intended.
- [ ] Identify important files with missing or outdated labels and agree an owner for remediation.
- [ ] Confirm users understand that Copilot can surface content they already have permission to access; labels and permissions must be correct first.
- [ ] Record any data types or locations that must be excluded from the pilot and apply the approved controls.

## Priority 6: End-user communications and enablement

- [ ] Send a short Finance-specific message explaining what Copilot is, what it can help with, and what it must not be used for.
- [ ] Tell users not to paste confidential information into unapproved tools or bypass existing data-handling rules.
- [ ] Explain that Copilot respects existing access but cannot correct incorrect SharePoint permissions.
- [ ] Provide examples for safe Finance tasks, such as summarising approved documents or preparing meeting notes.
- [ ] Provide a simple route for reporting incorrect access, unexpected content, poor answers, or suspected data exposure.
- [ ] Deliver a short demonstration and prompt guidance using non-sensitive sample data.
- [ ] Ask pilot users to complete a feedback form after the first week.
- [ ] Publish a service desk article covering sign-in, missing Copilot, access concerns, and escalation details.
- [ ] Name a Finance business owner, service desk contact, and technical escalation owner.

## Pilot approval and post-launch checks

- [ ] Permissions and oversharing gate signed off before license assignment.
- [ ] Pilot users confirmed licensed, MFA-ready, on supported Microsoft 365 Apps builds, and able to sign in.
- [ ] Sensitivity labels and data-handling guidance tested with representative, non-sensitive examples.
- [ ] End-user communication sent and support route confirmed.
- [ ] Pilot results reviewed against the agreed success measures.
- [ ] No unresolved high-severity access or data-protection issue remains before expanding beyond the pilot.
- [ ] Expand in controlled groups only after Finance, security, and service owners approve the next phase.
