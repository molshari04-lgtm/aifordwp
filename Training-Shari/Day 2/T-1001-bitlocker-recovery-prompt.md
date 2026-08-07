Summary (one line)
New Win11 laptop prompts for BitLocker recovery key on every boot.

Impact (who/how many/ business urgency)
- Who: One user/device (to-verify).
- How many: One device affected based on current report.
- Business urgency: High if user is locked out of daily use (to-verify).

known facts
- Device is a new Win11 laptop.
- BitLocker recovery key prompt occurs every boot.

Missing information to gather
- Exact recovery key prompt/error text.
- Whether TPM was recently cleared/reset (to-verify).
- Recent firmware/BIOS updates.
- Whether device is Autopilot/Intune managed (to-verify).
- Whether user can currently get past the prompt with the key (to-verify).

likely catagory
BitLocker/TPM configuration issue, possibly firmware or Secure Boot related (to-verify).

First diagnostic step
Check TPM status (tpm.msc) and BitLocker key protector status (manage-bde -status) to see if TPM binding was lost or a firmware change is triggering recovery mode.
