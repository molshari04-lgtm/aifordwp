# Prompt 4b: Missing Desktop Shortcuts

## Technical Action

**Working assumption:** evidence has confirmed that the Friday **Document Manager** deployment's post-install script removed or altered desktop shortcuts. The approved shortcut display name, executable target, working directory, icon path, affected user scope, Intune app/remediation assignment, and Configuration Manager collection are **to confirm** before remediation.

**Permission requirement:** Updating the Public Desktop or deploying a device-context Intune/SCCM remediation requires local administrator/SYSTEM permissions. Creating or changing Intune assignments requires Intune Administrator or Endpoint Manager Administrator permission. Creating or changing Configuration Manager deployments requires an authorized Configuration Manager role. Obtain incident/change approval before execution.

### 1. Stop the script from changing shortcuts again

**Intune console action:** Go to `Intune admin center > Apps > All apps > [Document Manager - to confirm] > Properties > Assignments > Edit`. Remove `[Legal Floor 6 deployment ring - to confirm]` from **Required**, then select **Review + save** and **Save**.

**SCCM console action:** Go to `Configuration Manager Console > Software Library > Application Management > Applications > [Document Manager - to confirm]`. Open the deployment targeted at `[Legal Floor 6 collection - to confirm]`, select **Delete**, and confirm deletion of the deployment assignment.

These actions stop new enforcement only. They do not restore shortcuts already removed or altered.

### 2. Restore confirmed shared shortcuts to all user profiles

For shortcuts that should appear for every user, deploy the following approved script in **SYSTEM/device context**. It creates the shortcut in `C:\Users\Public\Desktop`, which Windows presents to all user profiles. Do not use it until the values marked **to confirm** have been verified against the approved application package or a known-good device.

```powershell
param(
    [Parameter(Mandatory)] [string]$ShortcutName,
    [Parameter(Mandatory)] [string]$TargetPath,
    [string]$WorkingDirectory,
    [string]$IconLocation
)

$publicDesktop = Join-Path $env:PUBLIC 'Desktop'
$shortcutPath = Join-Path $publicDesktop "$ShortcutName.lnk"

if (-not (Test-Path -LiteralPath $TargetPath -PathType Leaf)) {
    throw "Confirmed shortcut target was not found: $TargetPath"
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $TargetPath
$shortcut.WorkingDirectory = if ($WorkingDirectory) { $WorkingDirectory } else { Split-Path -Path $TargetPath -Parent }
if ($IconLocation) { $shortcut.IconLocation = $IconLocation }
$shortcut.Save()
```

**Intune deployment action:** Package the approved script as a Win32 remediation/application deployment and assign it as **Required** to `[Floor 6 affected devices - to confirm]`, using device context. Use the confirmed values in the install command:

```text
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\Restore-DocumentManagerShortcut.ps1 -ShortcutName "[Document Manager - to confirm]" -TargetPath "[confirmed executable path - to confirm]" -WorkingDirectory "[confirmed working directory - to confirm]" -IconLocation "[confirmed icon path - to confirm]"
```

**SCCM deployment action:** Create a package/application deployment containing the approved script, use the same install command, deploy it as **Required** to `[Floor 6 affected devices - to confirm]`, and select **Whether or not a user is logged on** with **Run with administrative rights**.

### 3. Remediate the post-install script and validate

1. Correct or remove the confirmed shortcut-removal logic in `[Document Manager post-install script/package - to confirm]`.
2. Update the Intune Win32 app or SCCM application/package with the vendor-approved corrected version, detection rule, and install command.
3. Test on one approved affected device and one unaffected control device before broad deployment.
4. Verify that the shared shortcut exists in `C:\Users\Public\Desktop`, the target opens successfully, and the corrected deployment no longer removes it at next sign-in.
5. If the shortcut is intentionally per-user or OneDrive/Folder Redirection-managed, do **not** write to user desktops from SYSTEM. Confirm the policy/OneDrive owner and deploy the restoration in the affected user's approved context instead.

## Floor Message

We are investigating missing desktop shortcuts on Floor 6 and are restoring the approved shortcuts while we check the recent Document Manager rollout. This work does not remove your files or change your access. Please do not create replacement shortcuts yourself. If a shortcut is still missing after the update, contact the Service Desk with your computer name and the shortcut name so we can check your device.