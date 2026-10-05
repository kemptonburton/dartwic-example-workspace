# DARTWIC example workspace

This repository pairs with [dartwic-example-plugin](https://github.com/kemptonburton/dartwic-example-plugin). Add `example-workspace/` in the Interface; that folder is the actual DARTWIC workspace. `tools/` holds the launch and client scripts, `flight-computer/` holds the separate flight peer simulator, and `walkthroughs/` explains the operational examples. The pressure, tank, and temperature responses are illustrative software test signals.

## Start

1. Use DARTWIC Engine and Interface 2.0.0 or newer and the matching [example plugin](https://github.com/kemptonburton/dartwic-example-plugin). Core 2.0.0 packages will be published separately. The downloadable ZIP includes the built plugin at `example-workspace/default/downloads/plugin.zip`, so running that download needs no C++ compiler. The workspace runs seven tasks; your license must permit them.
2. Clone this repository into `workspaces/dartwic-example-workspace`, or extract `dartwic-example-workspace.zip` under `workspaces/`. Keep `example-workspace/`, `tools/`, `flight-computer/`, and `walkthroughs/` together.
3. Run the launcher in PowerShell 7 with your installed engine executable. It creates a separate local instance and prompts for your own license and password on first use.

```powershell
./tools/start-demo.ps1 -EngineExecutable 'C:/DARTWIC/engine/DARTWIC Engine.exe'
```

4. In the Interface, choose **Add workspace** and select `workspaces/dartwic-example-workspace/example-workspace`. The updated development Interface also accepts the repository root and resolves its nested workspace automatically; older Interface releases require the explicit `example-workspace/` folder. Do not select `default/` or `engine/`. It detects and connects to the running instance using `workspaces/dartwic-example-workspace/engine/instances/example-workspace/config.json`. You can also use **New connection** with the address and password shown by the launcher. Open **Schematics -> Mock Rocket Test**. Confirm CONNECTED and SENSOR VALID are 1 and the sample counter advances. The driver and Lua controllers start; RUN TEST stays off.
5. Start the flight application in a second terminal. The packaged ZIP includes this executable; for a source clone, build it with this repository's CMake project or use its Windows download:

```powershell
./flight-computer/bin/rocket-flight-peer.exe --transport custom
```

Ground receives on 17600 and sends to 17601. Flight uses the reverse endpoints. Flight-owned channels appear as `FLIGHT_COMPUTER:<name>`. The workspace sends only ambient temperature and run request to flight.

All walkthroughs use this workspace. Only the optional engine-to-engine exercise starts another engine; it does not require a second authored example workspace.

You can add `example-workspace/` directly without the launcher. The authored idle channels are tracked under `default/rapid/channel_snapshot.json`, and the Interface installs the plugin dependencies declared in `default/project.json`. Start that local instance from the Interface, then start the flight peer separately if needed.

## Storage layout

The workspace's portable settings live in `global_data/settings.json`; project overrides belong in `default/settings.json`. The rocket model is a shared asset at `global_data/assets/models/`, referenced as `assets/models/...` by its schematic. Tasks, scripts, modules, and authored channel definitions are portable too. Local instance configuration, passwords, license keys, recordings, and caches are not part of this repository or release archive.

Use Engine and Interface 2.0.0 or newer for layered settings and shared asset APIs. See the plugin's [storage and settings guide](https://github.com/kemptonburton/dartwic-example-plugin/blob/main/docs/storage-and-settings.md) for plugin settings, module settings, and Model3D asset examples.

The example plugin's settings panel saves a run label at workspace or project scope.
Open Example Notes after saving to see the effective label. Reset removes only
the chosen override; a project reset reveals the workspace label again. This
setting is operator metadata and does not change the simulated hardware.

## Operate and record

Before each exercise, open **Data -> Dataframes -> New dataframe**. Choose **Start now**, enter a run name, select pressure, voted temperature, spread, sensor validity, sample age, abort state, valve requests, valve positions, and igniter applied. Select **All** for ARGUS events and logs, then **Start dataframe**.

Turn RUN TEST on. The supply tank fills the run tank to 60%. The timeline closes the fill valve, applies the igniter for two seconds, then opens the engine feed valves. Pressure approaches 60 bar and voted temperature approaches 1200 K. Turn RUN TEST off to return to idle. The schematic shows FILL, FUEL, OXIDIZER, and VENT valves. Each symbol shows measured position and can toggle its request when the sequence has released that channel; the switches and readouts below make both values explicit. Requests, applied coils, and measured valve positions are separate channels.

Turn HIGH TEMP ON IGNITION on before a run to trigger an abort at ignition or during firing. It does not heat the tanks during filling. The other three fault switches support the advanced exercises. T2 disagreement produces a warning while the median remains useful. Missing readings retain their last values, set SENSOR VALID to 0, and increase sample age. Disconnection de-energizes device outputs. Check validity before interpreting retained values.

**Overtemperature or invalid readings assert the abort. Clearing the condition releases its overrides automatically; firing can resume if RUN TEST is still on.** Acknowledging or silencing an event does not clear a fault or release an active abort. Turn RUN TEST off before clearing the fault if you want to stay stopped.

Stop the dataframe after each exercise. Open its graph, events, and logs for the same time range. Compare requests, applied outputs, and measured positions; inspect channel authority and `commanded_by`. Export the dataframe ZIP to retain CSV and ARGUS records. Channels record on value change, so an unchanged value does not generate a new sample every tick.

## Walkthroughs

1. [Device driver and discovery](walkthroughs/01-device-driver.md)
2. [Fill and ignition timeline](walkthroughs/02-fill-test.md)
3. [Sensor scaling](walkthroughs/03-sensor-scaling.md)
4. [Sensor voting](walkthroughs/04-sensor-voting.md)
5. [Automatic abort](walkthroughs/05-automatic-abort.md)
6. [Double-acting valve templates](walkthroughs/06-valve-template.md)
7. [Sensor-warning templates](walkthroughs/07-warning-template.md)
8. [TEMPEST client](walkthroughs/08-tempest-client.md)
9. [Engine-to-engine peer](walkthroughs/09-engine-peer.md)
10. [Native C++ flight peer](walkthroughs/10-native-flight-peer.md)
11. [Custom flight transport](walkthroughs/11-custom-flight-peer.md)

## Stop

Turn RUN TEST off and clear injected faults. Stop the flight-peer terminal with Ctrl+C, then run `./tools/stop-demo.ps1`. The stop script stops this workspace's recorded engine and any recorded background flight peer, checking their executable paths first. An instance started through the Interface should be stopped there. Stopping a dataframe does not stop the device.

The plugin contains `engine/src/rocket_sim_driver.cpp`, `engine/include/rocket_sim_module.h`, `engine/src/rocket_discovery.cpp`, and `engine/src/example_transport.cpp`. This repository keeps the matching flight application in `flight-computer/main.cpp`; its build fetches a locked copy of the public plugin dependencies. Building source requires CMake, C++20, and vcpkg, but no private DARTWIC checkout. See [flight-computer/README.md](flight-computer/README.md).
