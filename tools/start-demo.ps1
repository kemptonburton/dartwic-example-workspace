param([Parameter(Mandatory=$true)][string]$EngineExecutable, [string]$EngineInstallation, [int]$Port=7400, [switch]$EngineOnly)
$ErrorActionPreference='Stop'
$repoPath=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$workspacePath=(Resolve-Path (Join-Path $repoPath 'example-workspace')).Path
$instancePath=Join-Path $repoPath 'engine/instances/example-workspace'
$snapshotPath=Join-Path $workspacePath 'default/rapid/channel_snapshot.json'
$seedPath=Join-Path $workspacePath '.startup/channel_snapshot.json'
if (!(Test-Path -LiteralPath $snapshotPath)) {
    New-Item -ItemType Directory -Force -Path (Split-Path $snapshotPath) | Out-Null
    Copy-Item -LiteralPath $seedPath -Destination $snapshotPath
}
$enginePath=(Resolve-Path -LiteralPath $EngineExecutable).Path
$groundPeerPort=$Port+10200
$flightPeerPort=$Port+10201
if ($Port -lt 1024 -or $flightPeerPort -gt 65535) { throw 'Choose a base port between 1024 and 55334.' }
$endpointPorts=@($Port,($Port+1),($Port+2))
if (!$EngineOnly) { $endpointPorts+=@($groundPeerPort,$flightPeerPort) }
foreach ($endpointPort in $endpointPorts) {
    if (Get-NetTCPConnection -LocalPort $endpointPort -State Listen -ErrorAction SilentlyContinue) { throw "Port $endpointPort is already in use." }
}
New-Item -ItemType Directory -Force -Path $instancePath | Out-Null
$configPath=Join-Path $instancePath 'config.json'
if (Test-Path -LiteralPath $configPath) { $config=Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json -AsHashtable }
else {
    $password=Read-Host 'Demo admin password' -MaskInput
    $license=Read-Host 'Your DARTWIC license key'
    $config=@{server_admin_password=$password;license_key=$license;allow_viewers=$true;run_caesar_startup_benchmark=$false;run_rapid_startup_benchmark=$false;run_rapid_recording_startup_benchmark=$false;rapid_fixed_channel_capacity=4096}
}
$config.workspace_root_directory=$workspacePath
if ($EngineInstallation) {
    $config.engine_installation_directory=(Resolve-Path -LiteralPath $EngineInstallation).Path
} elseif (!$config.engine_installation_directory) {
    $installationPath=Split-Path $enginePath
    if ((Split-Path $installationPath -Leaf) -eq 'bin') { $installationPath=Split-Path $installationPath }
    $config.engine_installation_directory=$installationPath
}
$config.active_project_name='default'; $config.server_ip='127.0.0.1'; $config.server_port=$Port
$config | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $configPath -Encoding utf8
$connections=@()
if (!$EngineOnly) {
    $peerPath=Join-Path $PSScriptRoot 'peer-connection.json'
    $peer=Get-Content -LiteralPath $peerPath -Raw | ConvertFrom-Json -AsHashtable
    $peer.receive_endpoint="tcp://127.0.0.1:$groundPeerPort"
    $peer.send_endpoint="tcp://127.0.0.1:$flightPeerPort"
    $connections=@($peer)
}
$connectionsPath=Join-Path $workspacePath 'default/edge_node_connections.json'
if ($EngineOnly -or $Port -ne 7400 -or !(Test-Path -LiteralPath $connectionsPath)) {
    @{schema_version=1;connections=$connections} | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $connectionsPath -Encoding utf8
}
$env:DARTWIC_CONFIG_DIR=$instancePath
$engineProcess=Start-Process -FilePath $enginePath -WorkingDirectory (Split-Path $enginePath) -WindowStyle Hidden -RedirectStandardOutput (Join-Path $instancePath 'engine.stdout.log') -RedirectStandardError (Join-Path $instancePath 'engine.stderr.log') -PassThru
@{engine_pid=$engineProcess.Id;engine_path=$enginePath;port=$Port} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $instancePath 'demo-processes.json')
Write-Host "Engine PID $($engineProcess.Id); connect to 127.0.0.1:$Port and open Mock Rocket Test."
if (!$EngineOnly) { Write-Host "Flight command: ./flight-computer/bin/rocket-flight-peer.exe --transport custom --receive-endpoint tcp://127.0.0.1:$flightPeerPort --send-endpoint tcp://127.0.0.1:$groundPeerPort" }
