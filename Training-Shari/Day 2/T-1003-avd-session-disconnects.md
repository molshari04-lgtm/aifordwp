Summary (one line)
Azure Virtual Desktop session disconnects after roughly 10 minutes, then reconnects.

Impact (who/how many/ business urgency)
- Who: One user (to-verify).
- How many: One user affected based on current report.
- Business urgency: Disruptive to continuous work (urgency to-verify).

known facts
- AVD session disconnects after approximately 10 minutes.
- Session reconnects afterward.

Missing information to gather
- Network type/stability at time of disconnect (Wi-Fi, VPN, wired) (to-verify).
- Whether other AVD users are affected (to-verify).
- Client app/version used (to-verify).
- Any error/event shown on disconnect (to-verify).
- Whether this started recently or has always occurred (to-verify).

likely catagory
AVD session/network connectivity issue, possibly client-side network instability or session host timeout (to-verify).

First diagnostic step
Check the network connection stability (packet loss/latency) during a session and review AVD client-side logs or Event Viewer for disconnect reason codes.
