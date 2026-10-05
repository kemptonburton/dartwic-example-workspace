# Run a fill and ignition timeline

Open `example-workspace/default/scripts/test_sequence.dcode` and its `rocket_test` task. The file runs as **Lua**; no native compilation is needed.

1. Start a dataframe, then turn **RUN TEST** on.
2. Observe phase 1: the double-acting fill valve opens, the supply level falls, and the run tank rises to 60%.
3. Observe phase 2: fill closes and the igniter is applied for two seconds. Feed valves stay closed.
4. Observe phase 3: the engine feed valves open. Pressure approaches 60 bar and temperature approaches 1200 K while the run tank drains.
5. Turn RUN TEST off. Phase returns to 0, feed valves close, and igniter applied becomes 0.

The timeline starts one ordered operation at T+0. Its fill loop checks measured level before moving to ignition; `wait_for 100ms` lets the timeline continue ticking while that operation waits. Ignition advances only while the abort is clear. The request helper handles an ARGUS override arriving between the condition check and a command, then retries on the next loop. Firing keeps applying its requests after an automatically released abort. The supply replenishes in idle so you can repeat the exercise.

Failure exercise: turn **HIGH TEMP ON IGNITION** on before RUN TEST. Filling still works. At ignition, temperature becomes 1800 K and the abort disables the igniter and closes the valves. Clear the switch to release the override and continue ignition/firing. Turn RUN TEST off first if you want to remain stopped. Acknowledging or silencing the event does not release it.

[Review the dataframe](../README.md#operate-and-record): compare both tank levels, phase, requests, applied outputs, valve positions, and stage logs. Change the 60% target or two-second ignition delay in this file, save/activate it, and repeat.
