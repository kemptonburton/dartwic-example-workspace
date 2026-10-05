# Build a device driver and discovery loop

The public example plugin keeps its small `example_device` starter and adds `rocket_sim`. Open `engine/include/rocket_sim_module.h`, `engine/src/rocket_sim_driver.cpp`, and `engine/src/rocket_discovery.cpp` in that plugin source.

1. Start the workspace using [Start](../../README.md#start). Open **Modules -> rocket_device** and the `rocket_read` and `rocket_write` tasks. Both select that module. Their binding tables map each device field directly to a state channel. The read table maps measurements and applied feedback to output channels; the write table maps command channels to coil and igniter fields. The `rocket_sim` prefix names only the fault and phase controls.
2. In `on_configure`, validate the bindings, create channels, and assign measurement units and read-only authority. In `on_start`, keep the module and mappings in `TaskRuntime` context. The read callback publishes mapped device state; the write callback reads mapped commands. The simulated module uses a mutex because the two tasks share it. To try a remap, create a channel named `rocket_sim_extra_flow`, change only the `flow` row in the read task, save, and compare it with the other measurements. Restore `rocket_sim_flow` before running the sequence.
3. Run the sequence. Compare `rocket_sim_fuel_request`, `rocket_sim_fuel_open_coil`, `rocket_sim_fuel_open_applied`, and `rocket_sim_fuel_position`. A requested operation is not proof of its applied output or measured position.
4. Open **Logs** and filter the **Rocket device** stream. Observe coil transitions, igniter changes, task lifecycle, and fault recovery. The write task's `on_end` de-energizes outputs.

The discovery loop runs at 1 Hz. Its endpoint check is a simulated presence flag; replace that check with your device probe. It logs appearance/disappearance, suppresses duplicate configured modules, refreshes a presence lease, respects engine-scoped muting, and withdraws stale offers through `dartwic.module-discovery`. Provisioning supplies the module type and explicit read/write task types, as the Modbus plugin does.

Inject **DISCONNECT DEVICE**. Device validity becomes 0, outputs de-energize, and discovery logs disappearance. Clear it and observe rediscovery and valid samples. To try provisioning itself, stop/delete the two driver tasks and module in a disposable copy, then accept the discovery notification. Select the discovered module in the generated task editors. Restore the original workspace copy afterward.

[Record and review](../../README.md#operate-and-record) the failure and recovery. Use the device log timestamps to explain the delay between a request and feedback.
