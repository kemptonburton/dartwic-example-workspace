# Vote three temperature sensors

Open `default/scripts/sensor_voting.dcode`. One calculation publishes the median of T1/T2/T3; another publishes their spread. Voting and detecting disagreement are separate jobs.

1. Start a dataframe with all three temperatures, the voted value, and spread.
2. Run the test. Normal temperatures differ by about 2 K overall; the median approaches 1200 K.
3. Inject **SENSOR BIAS**. T2 rises by 350 K, spread exceeds 100 K, and the disagreement warning fires. The median remains close to the two agreeing sensors.
4. Clear the fault. Spread returns to about 2 K and the warning condition clears.

A median does not prove three sensors are healthy. This simulation has one shared validity flag; a real driver should publish per-sensor validity and freshness before selecting a voting quorum.

Failure exercise: inject **MISSING READINGS** instead. All readings are retained and invalid, so voting cannot manufacture a fresh measurement. The abort fires despite a plausible median. Clear the fault and confirm resumed samples.

[Review the dataframe](../../README.md#operate-and-record) with the warning occurrence and raw series. This shows why a voted value alone is insufficient for operational review.
