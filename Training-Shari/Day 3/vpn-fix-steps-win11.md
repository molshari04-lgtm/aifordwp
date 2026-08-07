1. Confirm scope
- Check if this is one device or multiple devices after Win11 upgrade.

2. Validate client state
- Confirm whether the legacy VPN client was removed during upgrade.
- Confirm whether the new VPN client is present and healthy.

3. Clear stale VPN config
- Remove stale VPN vendor entries under HKLM\SOFTWARE\<vendor> (match your org's VPN vendor path).

4. Re-deploy via Intune
- Force an Intune sync on the affected device.
- Confirm new VPN client deployment completes successfully.

5. Re-apply VPN policy
- Ensure split-tunnel configuration is applied from policy.
- Confirm route table/DNS behavior is as expected for internal resources.

6. Verify end-to-end
- Connect VPN, then test access to all required internal subnets/resources.
- Confirm no data loss and user can work normally.

7. Prevent recurrence
- Update/fix the Intune detection rule gap so upgraded Win11 devices always trigger redeployment automatically.
