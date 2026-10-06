param(
    [string]$FlightExecutable,
    [ValidateSet('custom','native')][string]$Transport='custom',
    [string]$HostAddress='127.0.0.1',
    [ValidateRange(1,65535)][int]$Port=7400,
    [string]$ReceiveEndpoint='tcp://127.0.0.1:17601',
    [string]$SendEndpoint='tcp://127.0.0.1:17600'
)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'flight-demo-process.ps1')
$repoPath=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
if (!$FlightExecutable) { $FlightExecutable=Join-Path $repoPath 'flight-computer/bin/rocket-flight-peer.exe' }
$flightPath=(Resolve-Path -LiteralPath $FlightExecutable).Path
$statePath=Get-FlightDemoStatePath -RepositoryPath $repoPath
$recordPath=Join-Path $statePath 'process.json'
if (Get-RecordedFlightDemoProcess -RecordPath $recordPath) { throw 'The flight demo is already running. Stop it with tools/stop-demo.ps1 first.' }
if ($Transport -eq 'native' -and !$env:DARTWIC_PASSWORD) { throw 'Set DARTWIC_PASSWORD for the native flight peer before starting it.' }
$arguments=@('--transport',$Transport)
if ($Transport -eq 'custom') { $arguments+=@('--receive-endpoint',$ReceiveEndpoint,'--send-endpoint',$SendEndpoint) }
else { $arguments+=@('--host',$HostAddress,'--port',"$Port") }
New-Item -ItemType Directory -Force -Path $statePath | Out-Null
$flightProcess=Start-Process -FilePath $flightPath -ArgumentList $arguments -WorkingDirectory (Split-Path $flightPath) -WindowStyle Hidden -RedirectStandardOutput (Join-Path $statePath 'flight.stdout.log') -RedirectStandardError (Join-Path $statePath 'flight.stderr.log') -PassThru
@{pid=$flightProcess.Id;executable=$flightPath;start_time_ticks="$($flightProcess.StartTime.ToUniversalTime().Ticks)"} | ConvertTo-Json | Set-Content -LiteralPath $recordPath -Encoding utf8
Write-Host "Started flight demo PID $($flightProcess.Id) ($Transport). Logs: $statePath"
