1. Fix logon script/policy processing timing after sign-in
- Why likely: Drives disappear every morning but can be remapped manually, and the logon script is reported as unreliable post-Win11 migration. This strongly suggests script/policy processing is not completing at the right time (to confirm).
- Specific check: On an affected morning sign-in, verify whether the logon script actually executed and whether Group Policy/user policy processing completed successfully (to confirm) before network/VPN was ready.
- Action if confirmed: Correct the policy/logon processing behavior so drive mapping runs reliably at sign-in (for example, enforce synchronous user policy/logon processing where appropriate and ensure the mapping step runs after connectivity is available) (to confirm).

2. Fix network/VPN availability at logon (drives mapped before connectivity exists)
- Why likely: Missing mappings recur at morning login, which often aligns with users signing in before LAN/Wi-Fi/VPN path to file shares is fully available (to confirm).
- Specific check: Compare sessions where drives fail vs succeed and confirm whether share paths are reachable at sign-in time (UNC reachability and name resolution) (to confirm).
- Action if confirmed: Implement a sign-in flow that ensures network path readiness before drive mapping runs (for example, connectivity-first sign-in guidance and mapped-drive processing after network availability) (to confirm).

3. Repair Win11 migration side effects on drive-map method/path references
- Why likely: Issue started specifically after Win11 migration; existing mapping method may reference outdated assumptions from pre-upgrade behavior (to confirm).
- Specific check: Validate the current mapping configuration source (GPO/Intune/logon script), target share paths, and any environment/path dependency against Win11 state (to confirm).
- Action if confirmed: Update mapping configuration to Win11-valid references and redeploy the corrected mapping method to affected scope (to confirm).

4. Scope and remediate Finance-specific permissions or target-share changes
- Why likely: Current report is one Finance user, and the affected drives are Finance-related letters (S:, P:); access model or share targeting may be inconsistent post-migration (to confirm).
- Specific check: Confirm user/group membership and effective permissions to both share paths, and test direct UNC access when mappings are missing (to confirm).
- Action if confirmed: Correct group membership/share ACL targeting and re-validate persistent mapping at next sign-in (to confirm).

5. Resolve endpoint-specific profile/cache corruption affecting persistent mappings
- Why likely: If only one device/user is affected and central policy/config is correct, local profile state can prevent persistent mappings from restoring reliably (to confirm).
- Specific check: Compare behavior on another device/account with same policy and check whether issue is isolated to this user profile/device (to confirm).
- Action if confirmed: Rebuild/fix the affected user profile mapping state and re-apply the standard drive-mapping configuration (to confirm).

6. Correct conflicting dual-management of drive mapping (legacy + new policy overlap)
- Why likely: Post-migration environments sometimes have overlapping legacy script plus newer management profile causing race/conflict behavior (to confirm).
- Specific check: Identify all active mapping mechanisms on the device/user (legacy script, GPO preference, Intune-delivered config) and confirm duplication/conflict (to confirm).
- Action if confirmed: Remove the duplicate/conflicting mechanism and keep a single authoritative mapping method, then validate next-morning persistence (to confirm).
