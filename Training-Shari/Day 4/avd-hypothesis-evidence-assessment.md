1. Host-side graphics stack crash on SHFIN-01-A, specifically DWM failing in igdumd64.dll after the overnight image update
Judgement: Support
Evidence: 07:02:16 Event 1000 shows dwm.exe faulting in igdumd64.dll, followed by 07:02:18 Event 9009 showing DWM exited. The same pattern repeats at 07:02:46 Event 1000 and 07:03:01 Event 9009, and again at 07:08:24 Event 1000 for another user on the same host.

2. Network-only explanation
Judgement: Contradict
Evidence: The disconnects occur immediately after the host crash events, not after a network-loss event. The key sequence is 07:02:16 Event 1000, then 07:02:17 Event 40, and 07:02:18 Event 9009. The same host-only crash pattern repeats at 07:02:46 to 07:02:47 and 07:08:24.

3. Session-host-timeout explanation
Judgement: Contradict
Evidence: The disconnects happen within seconds of DWM crashing, not at a timeout boundary. The decisive timestamps are 07:02:16 Event 1000, 07:02:17 Event 40, 07:02:18 Event 9009, then 07:02:46 Event 1000 and 07:02:47 Event 40. The unaffected comparison host also shows DWM starting normally at 07:01:46 Event 9011 with no Application Error events.
