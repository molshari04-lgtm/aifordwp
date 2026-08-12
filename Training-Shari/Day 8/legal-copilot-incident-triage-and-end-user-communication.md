# Legal Copilot Incident Triage and End-User Communication

## Incident triage

### Ticket 1: NDA cannot be summarised

**Likely cause, ranked:**
1. Permissions/access boundary
2. Sensitivity label restriction
3. Data indexing lag
4. License/client prerequisite issue
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Ask the paralegal to open the NDA directly from SharePoint while signed in with the correct work account.

**Is this actually a Copilot bug?** **No.** Hearing about a folder does not give someone access to it. If the paralegal cannot open the file directly, the access boundary explains the message. If direct access works, check the file's label and whether it was recently added or changed.

### Ticket 2: New associate cannot find case emails

**Likely cause, ranked:**
1. Data indexing lag
2. License/client prerequisite issue
3. Permissions/access boundary
4. Sensitivity label restriction
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Confirm the associate can see the required emails in Outlook and has an active Copilot add-on while signed in with the correct work account.

**Is this actually a Copilot bug?** **No.** The associate started this week, so mailbox access, account setup, or time for recent emails to become searchable is more likely. Check older messages as well as recent ones before escalating.

### Ticket 3: Settlement draft from an unrelated matter was surfaced

**Likely cause, ranked:**
1. Permissions/access boundary
2. Sensitivity label restriction
3. Guest/external sharing limitation
4. Data indexing lag
5. License/client prerequisite issue
6. Genuine Copilot fault

**Fastest check:** Review the partner's direct access to the folder and draft, including group membership and inherited permissions.

**Is this actually a Copilot bug?** **No.** Copilot generally surfaces content the user can already access. The immediate concern is that the partner has access to a matter they are not assigned to. Treat this as an access review and report it to the service desk or information security team.

### Ticket 4: Legal team lost Copilot access

**Likely cause, ranked:**
1. License/client prerequisite issue
2. Permissions/access boundary
3. Sensitivity label restriction
4. Data indexing lag
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Check whether the Legal group's Copilot add-on assignment or service plan changed, and whether another department still has access.

**Is this actually a Copilot bug?** **Unclear.** A sudden team-wide loss after working all week points first to a shared license, group assignment, policy, or service change. A genuine Copilot fault remains possible only after those checks and a wider service-status check.

### Ticket 5: Generic answers about contract templates

**Likely cause, ranked:**
1. Permissions/access boundary
2. Data indexing lag
3. License/client prerequisite issue
4. Sensitivity label restriction
5. Guest/external sharing limitation
6. Genuine Copilot fault

**Fastest check:** Ask the contract specialist to open one known template directly and ask Copilot about that exact file name.

**Is this actually a Copilot bug?** **Unclear.** If the specialist cannot open the template, access is the likely explanation. If the file is accessible but was recently added, indexing may need time. Only after a known, accessible, established file still produces generic answers should a Copilot fault be investigated.

## End-user communication

### 1. You cannot summarise a SharePoint NDA

Open the NDA directly in SharePoint while signed in with your work account. If you cannot open it, ask the folder owner to confirm whether you should have access. If you can open it, wait a little if the file was recently added or changed, then try again.

Contact the service desk if the problem continues. Share the file name, SharePoint location, the message shown, and whether you could open the file directly. Do not send the NDA itself unless the approved support process asks for it.

### 2. Copilot cannot find your case emails

First check that the emails are visible in Outlook and that you are signed in with your new work account. Because your account is new, recent messages may take some time to become available to Copilot. Try again later and check whether older case emails can be found.

Contact the service desk if older emails are also missing. Share your start date, mailbox address, approximate email dates, and any message shown. Do not copy confidential case details into an unapproved tool.

### 3. Copilot showed a settlement draft from another matter

Stop using the document and do not forward, download, edit, or share it. Report the access immediately to the service desk or information security team. You may also tell the matter owner that an access review is needed, but do not send the draft to them as an attachment.

Share the file name, folder location, and why you believe you should not have access. Do not include the settlement text or client details in your report unless the approved reporting process requires them.

### 4. Legal team has lost Copilot access

Check that you are signed in with your work account, then close and reopen the Microsoft 365 app. Do not repeatedly reinstall apps or change settings. If a colleague outside Legal uses Copilot, ask whether it is working for them.

Contact the service desk if the whole Legal team is affected. Share when the problem started, which apps are affected, the affected team, and any message shown. The service desk will check the team's access and service settings.

### 5. Copilot gives vague answers about contract templates

Open one known contract template directly and ask Copilot about its exact file name. If the template was recently added or changed, try again later. Check that you are signed in with your work account and can open the file yourself.

Contact the service desk if Copilot still cannot use a file you can open. Share the file name, library or folder location, when it was added or changed, and the answer Copilot gave. Do not paste client or contract text into an unapproved tool.

## Important

Microsoft 365 Copilot follows the access you already have; it cannot correct an incorrect permission. If Copilot shows you legal or client information you should not see, stop using it and report it immediately through the approved service desk or security route.
