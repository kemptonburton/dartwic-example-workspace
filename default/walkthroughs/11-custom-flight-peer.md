# Use a custom transport and matching flight application

Open `engine/src/example_transport.cpp` and `examples/flight-peer/main.cpp` in the public example plugin. Both use the same `TEMPEST::Transport` implementation with reversed endpoints.

1. Stop any native flight process, then restore the plugin-defined connection:

```powershell
python default/tools/peer_mode.py custom
./default/tools/flight-peer/bin/rocket-flight-peer.exe --transport custom
```

2. Ground binds PULL 17600 and connects PUSH 17601; flight binds PULL 17601 and connects PUSH 17600. Configure both sides together when changing ports.
3. Confirm battery and sample counter advance. Command telemetry rate and call `flight/set-mode`; inspect flight logs and the readiness event. Change ground ambient and confirm flight feedback changes.
4. Inspect request IDs, replies, and telemetry in the transport source. Frames use a four-byte big-endian length followed by JSON. Peer owns correlation, registration, heartbeat, and reconnect; the transport owns bounded queues and framing.

Failure exercise: stop/restart flight. Commands to the disconnected owner fail; reconnect restores new snapshots and acknowledged commands. This raw local transport has no authentication or encryption: use it on loopback for the exercise, and add your application's transport security before adapting it for a network.

[Record and review](../../README.md#operate-and-record) ownership, event history, and **Flight computer** logs. A queued frame is not an acknowledgement; a command timeout means completion is unknown and the application must reconcile state before retrying.
