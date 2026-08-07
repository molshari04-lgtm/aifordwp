Summary: After a Win11 migration, a Finance user's mapped S: and P: drives are missing each morning and require manual remapping; existing logon script appears unreliable post-upgrade.

Impact: 1 user currently reported (to confirm), recurring daily access disruption to finance file shares, moderate-to-high business impact if finance workflows depend on those drives (to confirm).

Known facts: Issue started after Win11 migration; affected user is in Finance; mapped drives S: and P: are missing each morning; user can remap manually; logon script exists; script appears not to run reliably after upgrade.

Missing info to gather: exact device/user scope (single user vs wider post-migration pattern) to confirm; whether script fails at every sign-in or only some; whether drives are available by UNC path when mapping is missing; whether login is on-network/VPN at sign-in; exact logon script path/assignment method (GPO/Intune/other) to confirm; relevant sign-in/logon script event logs and timestamps; whether any recent policy/profile changes occurred.

Likely category: Post-upgrade logon script/policy processing reliability issue affecting drive mapping persistence (to confirm).

First diagnostic step: Validate logon script execution at user sign-in on the affected Win11 device by checking sign-in/script processing logs and confirming whether S: and P: map successfully via script when network/VPN is available at logon.
