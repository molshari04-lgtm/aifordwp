Microsoft Intune is the cloud tool we use to manage and secure company devices. It manages Windows 11 laptops, plus macOS, iOS, and Android devices. In Intune, we apply settings like BitLocker encryption, password rules, Wi-Fi/VPN profiles, update rings, and compliance checks (for example, "is encryption on and antivirus healthy?").

A device is enrolled when the user signs in with their work account during setup, or when IT adds it through Autopilot/Company Portal. Enrollment links the device to our tenant so it can receive policies, apps, and security controls automatically.

In DWP day-to-day Win11 migration work, we mainly use Intune for two things:
1. Pushing required apps and configs after migration, such as Office, Teams, OneDrive, VPN, and baseline security settings.
2. Troubleshooting post-migration issues by checking compliance, sync status, and policy/app deployment errors, then forcing a sync or reassigning policies to fix access and performance problems.
