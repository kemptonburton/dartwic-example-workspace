# Subscribe and command with a TEMPEST client

Run from the extracted workspace. `default/tools/tempest_client.py` uses Python's standard library for HTTP operations and optional pyzmq for subscriptions. It registers an authenticated headless client, sends operations, and unregisters on exit.

```powershell
$env:DARTWIC_PASSWORD = Read-Host 'Demo admin password' -MaskInput
python default/tools/tempest_client.py
python -m pip install pyzmq
python default/tools/tempest_client.py --watch rocket_sim_pressure --seconds 10
python default/tools/tempest_client.py --set rocket_test_running 1
python default/tools/tempest_client.py --operation argus/query-logs '{"stream":"example_device_plugin/Rocket device","limit":10}'
```

Start a dataframe in the Interface before commanding. Expect fresh pressure snapshots during the subscription and stage changes after the command. The PUB endpoint is base port +1; HTTP operations use base port +2. Snapshots are delivery observations, not the driver's acquisition rate.

Failure exercise: stop/restart the dedicated engine, then rerun the client. A fresh registration is required after a process restart. The example exits on transport failure and never automatically retries a command with uncertain completion. `--viewer` permits read-only queries; commanding through it must fail. Headless clients cannot take operator manual override.

Turn RUN TEST off with the client afterward. [Review the dataframe](../../README.md#operate-and-record) and compare its stored samples with the subscription output. Use **Telemetry Exporter** for history queries/export; the operation reference defines the available `rapid/query-channel-range` and `rapid/query-channel-last-recorded` history calls.
