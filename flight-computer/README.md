# Flight computer simulator

`main.cpp` is the matching C++ TEMPEST Peer application for the mock rocket. It publishes flight-owned channels, ARGUS events, and logs; accepts a telemetry-rate write and a mode command; and reads the ground ambient channel. The same application supports native TEMPEST and the example plugin's custom transport.

The downloadable repository ZIP includes `bin/rocket-flight-peer.exe` and its adjacent ZeroMQ DLL. From the repository root, start the ground workspace first, then run:

```powershell
./flight-computer/bin/rocket-flight-peer.exe --transport custom
```

For native mode, stop the custom process, run `python tools/peer_mode.py native`, set `DARTWIC_PASSWORD` to the ground admin password, and run the same executable with `--transport native --host 127.0.0.1 --port 7400`. The native and custom walkthroughs in `walkthroughs/` cover expected readings, ownership, logs, disconnect rejection, and recovery.

To build from a source clone on Windows, set `VCPKG_ROOT` and run `cmake --preset windows-clang-release`, then `cmake --build --preset build-windows-clang-release --target rocket-flight-peer`. The executable appears under `build/windows-clang-release/Release/`; copy it and the ZeroMQ runtime DLL into `flight-computer/bin/`. CMake uses the sibling public example plugin in a DARTWIC checkout, or fetches a locked public plugin commit for a standalone clone. The source needs CMake, C++20, and vcpkg; the downloadable executable needs no toolchain or private checkout.

Flight receives on `tcp://127.0.0.1:17601` and sends to `tcp://127.0.0.1:17600` in custom mode. Ground uses the reverse endpoints. Set `--receive-endpoint` and `--send-endpoint` together if you change ports. This loopback example transport has no authentication or encryption; add transport security before adapting it to a network.
