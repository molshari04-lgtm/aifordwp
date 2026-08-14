# Preventive Process Change

Before any floor-scoped application deployment is expanded beyond its pilot device, require the change owner to record and obtain approval for evidence from a representative pilot covering normal sign-in, expected desktop shortcuts, and effective access to approved client content; block wider rollout until all three checks pass. Whether this control would have prevented the Legal Floor 6 incident is **to confirm**, because the available analysis does not confirm that the Friday deployment caused the reported issues.

## Sign-in and performance

For every pilot, capture a pre-deployment and post-deployment baseline for sign-in duration, sign-in failures, CPU and memory pressure, disk space, and application errors. Compare the pilot with an unaffected control device, define pass/fail thresholds in the change record, and require an approved rollback plan before deployment. Stop expansion when the pilot exceeds a threshold or shows a new sign-in or resource fault; resume only after Endpoint Engineering reviews the evidence and an approved test confirms the fix.

## Desktop shortcuts

Before deployment, inventory the expected shortcuts and identify whether each is owned by the application package, Public Desktop, the user profile, OneDrive, or folder redirection. Test installation, sign-in, policy processing, and application launch on an affected-scope pilot and an unaffected control. Block rollout if an expected shortcut is removed, altered, points to an unapproved target, or disappears after sign-in; require an approved package correction or remediation, detection rule, ownership decision, and rollback procedure before retrying.

## Client-content access

Before deployment, verify effective access on the pilot using approved test content and confirm that the deployment does not change group membership, inherited permissions, sharing, or access scope. Do not reproduce or search a real client matter to test the control. Security/Data Governance must approve the test evidence and any required Microsoft 365, Copilot, SharePoint, or document-management review before wider rollout.
