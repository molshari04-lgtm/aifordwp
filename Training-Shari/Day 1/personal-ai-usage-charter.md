# Personal AI Usage Charter — DWP Desktop/Endpoint Engineer

## Purpose
Personal working rules for using public AI assistants (e.g. ChatGPT, Copilot Chat, Gemini) safely and effectively in day-to-day desktop/endpoint support and engineering work.

## 1. Appropriate uses of public LLM help
- Explaining general Windows/Office error messages, event IDs, or registry keys (no real device identifiers).
- Drafting generic PowerShell/batch script templates for common admin tasks (disk cleanup, service checks, log parsing).
- Summarising or rephrasing anonymised issue descriptions into triage notes.
- Learning/explaining concepts: Group Policy, Intune, SCCM, networking basics, PowerShell syntax.
- Drafting generic documentation, checklists, or communication templates (no real names/systems).
- Brainstorming diagnostic steps for a described symptom (hypothetical, no live system data).

## 2. Uses that are NOT appropriate
- Pasting real end-user names, staff/NI numbers, addresses, case IDs, or any DWP claimant data.
- Pasting passwords, API keys, tokens, hashes, or connection strings — even "just to check format."
- Sharing real hostnames, IP addresses, internal URLs, or asset tags tied to production systems.
- Asking an assistant to generate scripts that will run unreviewed against production/live endpoints.
- Using AI output as the sole authority for security-sensitive changes (firewall, AV exclusions, admin rights).
- Uploading logs, screenshots, or exports without first stripping identifying/sensitive data.

## 3. Data-handling rule — end-user PII and credentials
**Never paste real PII or credentials into a public AI tool.** Before sharing any issue text, log snippet, or screenshot:
- Replace names with roles (e.g. "the user"), replace hostnames/asset tags with placeholders (e.g. `DEVICE-01`).
- Remove or mask usernames, email addresses, ticket numbers, IPs, and any secrets/keys.
- If unsure whether something counts as PII or a credential, treat it as sensitive and redact it — do not ask the AI to judge this for you.
- Credentials that have touched an AI prompt (even accidentally) must be treated as compromised and rotated.

## 4. Personal "generate then verify" rule
For any script, command, or system-change suggestion produced by an AI assistant:
1. **Never run it directly against a live/production device.** Read it fully and understand every line first.
2. **Test in a safe context** (sandbox VM, non-critical test device, or `-WhatIf`/dry-run flag) before real use.
3. **Verify against official documentation** (Microsoft Learn, internal DWP runbooks) for anything touching security, permissions, or data.
4. **Check for destructive potential** — deletions, registry edits, policy changes — and confirm rollback/backup exists first.
5. Only apply to a live endpoint once verified, and log what was changed and why per normal change-control process.

---
*This charter is a personal working practice and does not replace DWP information security policy or official AI usage guidance — where they conflict, official policy takes precedence.*
