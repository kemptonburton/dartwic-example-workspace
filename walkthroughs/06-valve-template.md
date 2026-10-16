# Generate double-acting valve controllers

Open `example-workspace/default/scripts/valves/double_acting_valves.dcode` and `valves.yaml`. Each YAML row creates a 10 Hz loop for fuel, oxidizer, fill, or vent, using the same simple pattern as the primary workspace.

The loop remembers the last request. When the request changes to `1`, it pulses the open coil for half a second; `0` pulses the close coil. After the pulse, it updates `rocket_sim_<valve>_state`. That channel records the completed command, while `rocket_sim_<valve>_position` comes from the simulated device.

1. Turn RUN TEST off and stop `rocket_test` before trying individual valves.
2. Request open, then close. Compare the request, commanded coil, applied coil, completed-command state, and measured position.
3. Leave the request unchanged and check that the loop does not repeat the pulse.
4. Wait for both coils to return to zero before stopping the valve loop.

A request that changes during the half-second wait is handled on a later iteration. This small example does not retry after a device disconnect or confirm movement from feedback. The driver rejects simultaneous coils. If you interrupt a pulse, check and clear the coil commands before restarting; stopping the loop does not itself write zero.

[Record and review](../README.md#operate-and-record) command versus applied pulse lengths. Add a valve with another YAML row and matching driver channels, then reactivate the DCode file. Keep RUN TEST off while checking the generated loop.
