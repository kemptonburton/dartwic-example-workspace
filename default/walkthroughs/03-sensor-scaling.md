# Scale a pressure sensor

Open `default/scripts/pressure_scaling.dcode`. It converts `rocket_sim_pressure_current_ma` into `rocket_sim_pressure` using `(value - 4) * 100 / 16`.

1. Start the workspace and a dataframe containing raw current and pressure.
2. With RUN TEST off, expect approximately 4 mA and 0 bar.
3. Turn RUN TEST on. During firing expect approximately 13.6 mA and 60 bar.
4. Inspect the calculation relationship in the pressure channel details. The dependent calculation runs when the input commits; it is not another polling task.

Failure exercise: inject **MISSING READINGS**. The last raw current and scaled pressure remain visible while SENSOR VALID becomes 0 and age rises. Do not label retained pressure as a new measurement. Clear the fault and confirm both channels update again.

[Review the dataframe](../../README.md#operate-and-record) using the two series and validity for the same interval. To adapt the example to another transmitter, change the current span and engineering range in this one calculation, then verify two known endpoints before using its result in control logic.
