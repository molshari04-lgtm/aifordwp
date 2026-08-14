# Ranked Analysis: Floor 6 Login Failures / Slow Logins

This assessment uses only the recorded incident scope. None of the causes below is confirmed.

## 1. Document management app deployment affecting sign-in

**Why this cause fits the scope facts:** The document management application was deployed specifically to Floor 6 on Friday afternoon, and Floor 6 users developed login failures or prolonged login times on the following Monday. The targeted scope and close timing make a deployment effect the leading hypothesis, although the weekend gap means the timing alone does not prove causation.

**Fastest check:** Compare the document management app deployment status and install timestamp on one affected Floor 6 device with an unaffected Floor 6 device, then check the affected device's sign-in event timestamps against the installation timestamp.

**Evidence that would confirm the app as the cause:** Affected devices consistently received the app or a related deployment component before symptoms began; the sign-in logs show the app, its service, script, policy, or installer activity delaying or failing during sign-in; and unaffected users/devices did not receive that version or component.

**Evidence that would rule out the app as the cause:** Affected and unaffected devices have the same app deployment state and version without a sign-in-log difference, affected users did not receive the app deployment, or the sign-in failure occurs without any related app, service, script, or installer activity.

## 2. Authentication or sign-in service issue affecting Floor 6 users

**Why this cause fits the scope facts:** Users report both inability to sign in and very slow sign-in, which can share an authentication or sign-in dependency. The reported scope is Floor 6, but it is not yet known whether the boundary is location, network, user group, or device configuration.

**Fastest check:** Capture the exact error and sign-in event logs from one affected device, then test whether the same affected user can sign in to another device.

## 3. Windows 11 or Intune configuration issue on the recently migrated floor

**Why this cause fits the scope facts:** All reported users are on a floor recently migrated to Windows 11 and enrolled in Intune. A configuration, policy, or device-management issue could affect the same population and can present as slow or failed sign-in. The scope does not establish that every affected device shares the same configuration state, so this remains to confirm.

**Fastest check:** Compare Windows version, Intune compliance status, and recently applied device or user policies between one affected and one unaffected Floor 6 device.

## Ranking Weighting

The Friday afternoon deployment followed by Monday morning symptoms gives the app deployment the highest rank because it is the only recorded change explicitly targeted at the affected floor and immediately preceding the incident. It is not decisive: the issue may have started only when users first signed in after the weekend, or it may be unrelated. Authentication and Windows 11/Intune causes remain credible until the checks above establish the actual sign-in failure point and compare affected versus unaffected devices.