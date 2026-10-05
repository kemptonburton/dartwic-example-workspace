# Generate sensor warnings

Open `default/scripts/warnings/sensor_warnings.dcode` and `sensors.yaml`. The YAML supplies channel names and low/high limits for temperature, pressure, and disagreement warnings.

1. Start the workspace and a dataframe with the sensor channels and ARGUS events/logs.
2. Inject SENSOR BIAS. The disagreement event fires when spread exceeds 100 K.
3. Clear it. The firing condition clears, while its occurrence remains available for review.
4. Inject MISSING READINGS. Validity becomes 0 and sample age grows; sensor warnings fire even when retained values sit inside their numeric limits.

The template checks validity and freshness before comparing bounds. `on_firing` logs changes to the live condition. Acknowledgement records operator attention; it does not change the sensor input.

Failure exercise: silence a warning while its condition is active, then clear the fault. Inspect the live firing state and the recorded occurrence separately. Reactivate after changing a YAML limit and verify which generated events use the new limit.

[Review the dataframe](../../README.md#operate-and-record) with sensor values, validity, age, and **Rocket warnings** logs. Add a warning by adding a YAML row; avoid copying a separate event block for every sensor.
