Summary (one line)
Company app installation fails from Company Portal with error 0x87D1041C.

Impact (who/how many/ business urgency)
- Who: Number of users affected (to-verify).
- How many: At least one device based on current report.
- Business urgency: Depends on whether app is business-critical (to-verify).

known facts
- Install attempted via Company Portal.
- Installation fails with error code 0x87D1041C.

Missing information to gather
- Device(s) affected (single vs multiple) (to-verify).
- Whether other Company Portal apps install successfully (to-verify).
- Device compliance/enrollment status in Intune (to-verify).
- Network/proxy restrictions during install (to-verify).
- App size and content delivery method (content push vs download) (to-verify).

likely catagory
Intune/Company Portal app deployment failure (to-verify root cause: network, compliance, or package issue).

First diagnostic step
Look up error 0x87D1041C in Intune app install logs (IME logs) or Microsoft documentation, and check device compliance status and Company Portal sync in Intune admin center.
