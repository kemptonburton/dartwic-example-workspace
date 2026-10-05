# Connect another engine

Use the same workspace for both engines. The peer exercise needs a second isolated instance with a different node name; no separate example workspace is needed.

1. Keep ground running at 127.0.0.1:7400. In a second terminal, extract the same download into a temporary directory and change that copy's node name:

```powershell
Expand-Archive ./mock-rocket-test.zip ./peer-test
Set-Location ./peer-test/mock-rocket-test
$workspace = Get-Content ./workspace.json -Raw | ConvertFrom-Json
$workspace.node_name = 'MOCK_ROCKET_SECONDARY'
$workspace | ConvertTo-Json | Set-Content ./workspace.json -Encoding utf8
./default/tools/start-demo.ps1 -EngineExecutable 'C:/DARTWIC/engine/DARTWIC Engine.exe' -Port 7800 -EngineOnly
```

The launcher creates separate runtime storage and prompts for that instance's credentials. `-EngineOnly` omits the custom flight link. Leave its local RUN TEST off.

2. Connect an Interface to 127.0.0.1:7800. In **Engine peers**, add a built-in **TEMPEST Engine Peer** to 127.0.0.1:7400 using the ground engine's password. Enable RAPID and ARGUS, then connect.
3. In **Channels**, inspect `MOCK_ROCKET_GROUND:rocket_sim_pressure`, `MOCK_ROCKET_GROUND:rocket_sim_phase`, and `MOCK_ROCKET_GROUND:rocket_sim_fuel_position`. Run the test from ground and confirm those remote readings follow it. Network Map identifies the two owning nodes. Unqualified channels belong to the secondary instance's own idle simulator.
4. Query a node-qualified ground channel or command the free `MOCK_ROCKET_GROUND:rocket_test_running` from secondary. Ground owns execution and recording.

Failure exercise: stop ground. Secondary retains last-known records, presents unavailable data, and rejects a new ground command. Restart ground and reconnect; confirm sample counters and snapshot timestamps advance again before commanding.

Record at ground and [review its dataframe](../../README.md#operate-and-record). Remote observations include network delay; keep the abort and valve controllers on ground. Stop secondary with its copy's stop script afterward.
