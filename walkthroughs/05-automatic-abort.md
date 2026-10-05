# Abort and recover automatically

Open `example-workspace/default/scripts/engine_abort.dcode`. Its trigger watches voted temperature above 1500 K or invalid device input. `on_firing` controls the shutdown overrides; event acknowledgement is separate.

1. Start a dataframe and run the test until phase 3.
2. Inject **HIGH TEMP ON IGNITION**. Voted temperature becomes 1800 K; abort active becomes 1; feed/fill requests become 0 and igniter applied becomes 0.
3. Inspect a feed request: the underlying owner is `task:rocket_test`, while the active controller and policy reflect the abort's `automatic_override`.
4. Acknowledge or silence the event while the fault remains active. Verify the shutdown remains applied.
5. Leave RUN TEST on and clear overtemperature. Abort active becomes 0, `free` releases the overrides, and the sequence's feed and igniter requests resume.

**Automatic release is intentional in this example.** Turn RUN TEST off before clearing the fault to remain idle. The code uses the live firing condition, not the event's board status, as the release criterion.

Failure exercise: inject **DISCONNECT DEVICE** during firing. Applied igniter goes off immediately in the device; retained temperatures become invalid. Clear the disconnect and verify valid samples and controller recovery. Finish with RUN TEST off.

[Review the dataframe](../README.md#operate-and-record), including abort transitions, requests, applied igniter, measured positions, and event/log timestamps. A command response does not establish physical shutdown timing.
