# Triage Summary: Copilot Unauthorized Client Matter Access

**Summary:** A paralegal reports that Copilot surfaced a client matter she states she has never had access to — a potential data access/permissions issue.

**Impact:** Currently reported by one user, but this is a **potential data confidentiality/security concern** (client matter data), which carries high business and legal/ethical urgency regardless of user count — must be treated as priority regardless of scope until scope is confirmed.

**Known facts:**
- One paralegal reported Copilot displayed content from a client matter.
- She states she has never had access to that matter.
- Timing coincides with the Friday rollout of the new document management app on the same floor (correlation only, not confirmed causation).

**Missing information to gather:**
- Which specific client matter and what content was shown (to confirm).
- The paralegal's actual permissions/group memberships vs. the matter's access control list (to confirm).
- Whether this is a Copilot/M365 permissions inheritance issue tied to the new document management app's SharePoint/permission structure (to confirm).
- Whether any other users have seen unexpected content (to confirm — needs to be asked proactively, not just wait for reports).
- Whether the content was viewed only via Copilot summarization or if the underlying document itself was also accessible directly (to confirm).

**Likely category:** Data access control / permissions misconfiguration, potentially introduced by the new document management app's integration with Copilot/SharePoint indexing. To confirm — requires immediate security/compliance escalation given client confidentiality implications.

**Suggested first diagnostic step:** Escalate immediately to security/compliance and check the specific matter's access control list against the paralegal's group memberships; review Copilot/SharePoint audit logs for the access event before any further investigation.
