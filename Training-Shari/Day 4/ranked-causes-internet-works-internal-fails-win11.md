1. VPN connected but missing correct route/profile after migration  
Why it fits: Internet works, but internal-only resources fail; one device affected points to a device-specific VPN/profile issue, common after migration.  
Fastest check: Confirm VPN is connected, then run `route print` and verify routes exist for internal network ranges.

2. Device non-compliant in Intune causing conditional access block to internal apps  
Why it fits: Post-migration, one laptop may fall out of compliance while others stay healthy; internet remains normal, but SharePoint/internal access is denied.  
Fastest check: In Intune/Entra, check that device state is `Compliant` and user sign-in logs show no conditional access block.

3. Corrupted or stale Windows credentials/tokens (WAM/ADAL/Kerberos)  
Why it fits: SharePoint and mapped drives rely on enterprise auth; migration can leave stale tokens on one device while general internet still works.  
Fastest check: Open `cmdkey /list` and inspect for old/duplicate entries for Microsoft 365/fileserver targets; compare with a working device.

4. DNS suffix or corporate DNS resolution not applying on this laptop  
Why it fits: Public internet uses public DNS, but internal SharePoint/fileshares need corporate DNS; one-device scope matches post-migration policy miss.  
Fastest check: Run `nslookup` for internal SharePoint/fileserver FQDN using current adapter DNS and verify it resolves to internal addresses.

5. Mapped drive persistence using old server path or unavailable legacy namespace  
Why it fits: After migration, one profile may retain old mappings while others got updated via policy/script; internet unaffected, internal drives fail.  
Fastest check: Run `net use` and validate each mapping target path against the current approved server/namespace.
