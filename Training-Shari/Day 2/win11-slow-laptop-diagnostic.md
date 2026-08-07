Likely causes
- Background updates or Windows 11 feature update still finishing post-install (common on machines <2 weeks old).
- High disk/CPU usage from antivirus/Defender scan, OneDrive/Teams sync, or indexing service.
- Insufficient RAM/disk headroom for installed security/management agents (Intune, SCCM client, EDR).
- Outlook/app-specific issue (e.g., large mailbox, corrupt profile) rather than a system-wide fault.
- Malware/resource-hogging process (to confirm — no evidence yet, but shouldn't be ruled out).

3 questions to ask
1. Is the slowness constant, or does it happen only when specific apps (e.g., Outlook) are open?
2. Has anything changed recently — updates installed, new software, or a policy push — around when the slowness started?
3. Is the device on-site, on VPN, or connecting to network drives when it's slow?

First diagnostic step
Open Task Manager during the slowdown and check CPU, memory, and disk usage to identify which process/resource is the bottleneck before deciding whether this is a system-wide performance issue or an app-specific one.
