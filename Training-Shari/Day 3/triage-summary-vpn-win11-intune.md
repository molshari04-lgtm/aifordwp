Summary: Finance user on Windows 11 can connect VPN, but cannot reach internal resources after a Win11 upgrade last week on an Intune-managed device.

Impact: 1 user currently reported (to confirm); access to internal systems appears blocked for this user; business impact potentially high for Finance duties (to confirm).

Known facts: User is in Finance; device is on Windows 11; Win11 upgrade occurred last week; VPN connection succeeds; internal resources are not reachable; device is managed via Intune.

Missing info to gather: exact internal resources affected (file shares, intranet, app servers) to confirm; whether issue affects only this user or multiple post-upgrade users (to confirm); whether access by IP works while hostname fails (to confirm); DNS resolution behavior while VPN is connected (to confirm); VPN client version and deployment state on the device (to confirm); split-tunnel policy/routes applied after upgrade (to confirm); whether stale legacy VPN components remain (to confirm); timing/pattern of failure and any user-visible error text (to confirm).

likely category: Post-upgrade VPN client/configuration issue on Intune-managed Win11 endpoint, likely route/DNS/split-tunnel policy mismatch (to confirm).

First diagnostic step: With VPN connected, test reachability to a known internal resource by hostname and by IP, then review the applied VPN profile/routes on the device to determine whether the failure is DNS-related or routing/policy-related.
