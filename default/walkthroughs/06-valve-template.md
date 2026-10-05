# Generate double-acting valve controllers

Open `default/scripts/valves/double_acting_valves.dcode` and `valves.yaml`. The YAML generates one periodic controller for fuel, oxidizer, fill, and vent.

1. Turn RUN TEST off, then stop the `rocket_test` task to release its valve requests.
2. Use a valve switch to request open, then close. Compare request, open/close coils, applied coils, and position.
3. Observe a 0.2-second command pulse followed by both coils off. The opposite coil is cancelled before starting a new pulse.
4. Stop that valve task during a pulse. Its `end:` requests both coils off and releases their authority. Restart it to initialize a new pulse state.

The driver independently rejects simultaneous coils and logs the rejection. The template pulse bounds the command; it is not a hardware safety timer or a guaranteed physical pulse duration. Position remains latched after a pulse in this simulated double-acting device.

Failure exercise: disconnect the device mid-pulse, then reconnect. The controller resets its remembered request while disconnected and retries the requested position after valid connection. Confirm both applied coils are never on together.

[Record and review](../../README.md#operate-and-record) command versus applied pulse lengths. Add a valve by adding one YAML row with a new `valve` name and corresponding driver channels. Reactivate the template after editing YAML; verify the generated task before starting it. Restart `rocket_test` with RUN TEST off afterward.
