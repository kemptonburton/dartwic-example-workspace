# Flight computer simulator

`main.cpp` is the separate C++ TEMPEST Peer application for the mock rocket. It publishes flight-owned altitude, velocity, phase, battery, ARGUS events, and logs. It accepts telemetry-rate writes and launch/land operations. Launch requires the ground `rocket_qd_released` channel. The same application supports native TEMPEST and the example plugin's custom transport.

The repository release is source-only. Build `bin/rocket-flight-peer.exe` and copy its adjacent ZeroMQ DLL as described below. From the repository root, start the ground workspace first, then run:

```powershell
./flight-computer/bin/rocket-flight-peer.exe --transport custom
```

To run it in the background instead, use `./tools/start-demo.ps1` and `./tools/stop-demo.ps1`. These scripts manage only the flight peer, never the Engine or workspace configuration. Flight process records and stdout/stderr logs are stored outside the repository under local application data. The start script reports an immediate exit with the error log; after startup, check the Engine peer status to confirm registration and advancing snapshots. Use `-FlightExecutable` for an alternate build, or `-ReceiveEndpoint` and `-SendEndpoint` to change custom transport endpoints.

For native mode, stop the custom process, run `python tools/peer_mode.py native`, set `DARTWIC_PASSWORD` to the ground admin password, and run the same executable with `--transport native --host 127.0.0.1 --port 7400`. The native and custom walkthroughs in `walkthroughs/` cover expected readings, ownership, logs, disconnect rejection, and recovery.

The equivalent background command is `./tools/start-demo.ps1 -Transport native -HostAddress 127.0.0.1 -Port 7400`. Set `DARTWIC_PASSWORD` first; the script does not store it in its process record.

To build from a source clone on Windows, set `VCPKG_ROOT` and run `cmake --preset windows-clang-release`, then `cmake --build --preset build-windows-clang-release --target rocket-flight-peer`. The executable appears under `build/windows-clang-release/Release/`; copy it and the ZeroMQ runtime DLL into `flight-computer/bin/`. CMake uses the sibling public example plugin in a DARTWIC checkout, or fetches the pinned public plugin commit for a standalone clone. The source needs CMake, C++20, and vcpkg.

Flight receives on `tcp://127.0.0.1:17601` and sends to `tcp://127.0.0.1:17600` in custom mode. Ground uses the reverse endpoints. Set `--receive-endpoint` and `--send-endpoint` together if you change ports. This loopback example transport has no authentication or encryption; add transport security before adapting it to a network.
