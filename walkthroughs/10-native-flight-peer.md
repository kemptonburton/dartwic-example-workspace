# Run a native C++ flight peer

Use the same `rocket-flight-peer.exe` with its native ZeroMQ transport. Developer source and build steps are in this repository's `flight-computer/` folder; no private checkout is required.

1. Stop the custom flight process and remove its saved connection with the mode helper.

```powershell
$env:DARTWIC_PASSWORD = Read-Host 'Demo admin password' -MaskInput
python tools/peer_mode.py native
./flight-computer/bin/rocket-flight-peer.exe --transport native --host 127.0.0.1 --port 7400
```

2. Confirm **FLIGHT_COMPUTER** connects in Network Map and its battery/sample counter advance. Both peer and protocol IDs are `tempest.engine`.
3. Open **Rocket Flight**. Command `FLIGHT_COMPUTER:telemetry_rate_hz` to 10, then start `rocket_launch_sequence`. It releases `rocket_qd_released` and invokes the saved `launch-rocket` pinned TEMPEST operation.
4. Confirm flight phase, altitude, and velocity change. Start `rocket_land_sequence` to invoke `land-rocket`; confirm descent and landing. Review the flight-owned ARGUS readiness event and **Flight computer** log stream.

Failure exercise: stop the flight process. After disconnect is detected, commanding its channels must fail. Restart the same command and confirm advancing snapshots, a new session, recovered logs, and successful commands. Ownership remains FLIGHT_COMPUTER throughout.

[Record and review](../README.md#operate-and-record) at ground. Native and custom modes use the same handlers; do not run both with the same node name simultaneously. Return to the custom mode walkthrough for the final demo setup.
