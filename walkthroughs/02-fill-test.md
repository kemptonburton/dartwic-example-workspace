# Run a fill and ignition timeline

Open **Engine Test Fire**, `example-workspace/default/scripts/ox_tank_sim.dcode`, and `test_sequence.dcode`. The periodic physics task computes tank fill and pressure from applied valve positions. The `engine_tank_fill` state machine commands fill and vent; `engine_ignition` runs the firing sequence. The device read task supplies chamber measurements and valve feedback.

1. Turn **RUN TEST** on. At T-2m, answer **Engine test recording** with a run name. The setup bucket creates a dataframe; the mission clock holds at the next bucket if setup is unfinished.
2. At T-1m, answer **Ox tank fill target** with `60`. Watch the measured fill approach that percentage. Supply level stays at 100%; the controller vents when ox pressure reaches 90% of supply pressure, then resumes filling after pressure falls to 500.
3. The tank-fill bucket waits for completion and a return to isolate. If it reaches T0 first, its scheduled hold keeps ignition from starting early.
4. At T+0s, the ignition sequence energizes the simulated igniter for two seconds, then opens the feed valves. During its eight-second firing interval, pressure approaches 60 bar and voted temperature approaches 1200 K.
5. After ignition completes, its end handler closes and releases the outputs. The T+15s cleanup bucket stops the dataframe. Turn RUN TEST off to stop early; the stop handler ends the recording and stops ignition.

Confirm the current state and completion channels as well as the task cards. An abort reaction can take control of outputs while the timeline is still running. Stop the test before clearing a fault when you want to remain idle.

[Review the dataframe](../README.md#operate-and-record): compare fill target, fill, pressure, valve position, and phase. Repeat with another fill target through the prompt. To change ignition duration, edit the waits in `test_sequence.dcode`, activate it while the procedure is stopped, and run a fresh test.

Activating `test_sequence.dcode` also labels `rocket_sim_phase`: `0` idle, `1` tank fill, `2` ignition, and `3` firing.
