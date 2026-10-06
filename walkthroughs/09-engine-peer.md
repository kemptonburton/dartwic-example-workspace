# Connect another engine

Use the same workspace for both engines. The peer exercise needs a second isolated instance with a different node name; no separate example workspace is needed.

1. Keep ground running at 127.0.0.1:7400. In a second terminal, extract the same download into a temporary directory and change that copy's node name:

```powershell
Expand-Archive ./dartwic-example-workspace.zip ./peer-test
Set-Location ./peer-test/dartwic-example-workspace
$workspace = Get-Content ./example-workspace/workspace.json -Raw | ConvertFrom-Json
$workspace.node_name = 'MOCK_ROCKET_SECONDARY'
$workspace | ConvertTo-Json | Set-Content ./example-workspace/workspace.json -Encoding utf8
```

In the Interface, add this copy's `example-workspace/`, set its local Engine port to 7800, and prepare its plugin dependencies. Before starting it, remove or disable the copied custom flight connection so it does not bind ground's custom transport port. Start this second Engine through the Interface and leave its local RUN TEST off. The flight start/stop scripts do not manage either Engine.

2. Connect an Interface to 127.0.0.1:7800. In **Engine peers**, add a built-in **TEMPEST Engine Peer** to 127.0.0.1:7400 using the ground engine's password. Enable RAPID and ARGUS, then connect.
3. In **Channels**, inspect `MOCK_ROCKET_GROUND:rocket_sim_pressure`, `MOCK_ROCKET_GROUND:rocket_sim_phase`, and `MOCK_ROCKET_GROUND:rocket_sim_fuel_position`. Run the test from ground and confirm those remote readings follow it. Network Map identifies the two owning nodes. Unqualified channels belong to the secondary instance's own idle simulator.
4. Query a node-qualified ground channel or command the free `MOCK_ROCKET_GROUND:rocket_test_running` from secondary. Ground owns execution and recording.

Failure exercise: stop ground. Secondary retains last-known records, presents unavailable data, and rejects a new ground command. Restart ground and reconnect; confirm sample counters and snapshot timestamps advance again before commanding.

Record at ground and [review its dataframe](../README.md#operate-and-record). Remote observations include network delay; keep the abort and valve controllers on ground. Stop secondary through the Interface afterward.
