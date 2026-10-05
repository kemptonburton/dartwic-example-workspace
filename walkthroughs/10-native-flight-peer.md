# Run a native C++ flight peer

Use the same `rocket-flight-peer.exe` with its native ZeroMQ transport. Developer source and build steps are in this repository's `flight-computer/` folder; no private checkout is required.

1. Stop the custom flight process and remove its saved connection with the mode helper.

```powershell
$env:DARTWIC_PASSWORD = Read-Host 'Demo admin password' -MaskInput
python tools/peer_mode.py native
./flight-computer/bin/rocket-flight-peer.exe --transport native --host 127.0.0.1 --port 7400
```

2. Confirm **FLIGHT_COMPUTER** connects in Engine peers and its battery/sample counter advance. Both peer and protocol IDs are `tempest.engine`.
3. Command `FLIGHT_COMPUTER:telemetry_rate_hz` to 10. Call `flight/set-mode` with `{"mode":"test"}` using the operation browser. Expect acknowledged applied mode and a flight log.
4. Change `rocket_sim_ground_ambient`. Flight's `ground_ambient` follows the ground snapshot; flight sends `rocket_sim_flight_check=1` back to ground after registration. Review the flight-owned ARGUS readiness event and **Flight computer** log stream.

Failure exercise: stop the flight process. After disconnect is detected, commanding its channels must fail. Restart the same command and confirm advancing snapshots, a new session, recovered logs, and successful commands. Ownership remains FLIGHT_COMPUTER throughout.

[Record and review](../README.md#operate-and-record) at ground. Native and custom modes use the same handlers; do not run both with the same node name simultaneously. Return to the custom mode walkthrough for the final demo setup.
