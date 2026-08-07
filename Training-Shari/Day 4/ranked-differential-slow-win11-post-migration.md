1. Background indexing/sync catch-up to confirm  
Why likely: Right after migration, Windows Search, OneDrive, Outlook cache, and profile data often re-index/re-sync in bulk, which can temporarily drive CPU, disk, and network use.  
Fastest check: In Task Manager, see if SearchIndexer, OneDrive, or Outlook processes are sustaining high usage for extended periods.

2. Windows Update and post-upgrade servicing to confirm  
Why likely: Newly migrated Win11 devices commonly run cumulative updates, driver updates, .NET optimization, and component cleanup in the background.  
Fastest check: Check Windows Update history/status for "installing/pending restart" and correlate with high CPU/disk in Task Manager.

3. Endpoint security baseline re-application to confirm  
Why likely: After re-enrollment or policy refresh, Defender scans and security agent policy pulls can spike resource use in managed enterprise builds.  
Fastest check: Check Task Manager for MsMpEng.exe or enterprise security agent processes showing sustained CPU/disk activity.

4. Startup/load inflation from migrated app set to confirm  
Why likely: Post-migration images often include multiple auto-start enterprise apps (Teams, VPN, telemetry, updaters) that all initialize at sign-in.  
Fastest check: Review Startup Apps impact in Task Manager and confirm whether many "High impact" entries are enabled.

5. Driver mismatch or hardware power-state regression to confirm  
Why likely: Win11 migration can leave older or generic drivers (chipset/storage/graphics), causing poor performance under normal load.  
Fastest check: In Device Manager, look for warning icons or recently changed/unknown drivers and confirm driver dates/providers for key devices.
