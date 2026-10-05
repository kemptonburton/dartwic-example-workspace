$workspacePath=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$ErrorActionPreference='Stop'
$instancePath=Join-Path (Split-Path $workspacePath) ('engine/instances/' + (Split-Path $workspacePath -Leaf))
$record=Get-Content -LiteralPath (Join-Path $instancePath 'demo-processes.json') -Raw | ConvertFrom-Json
if ($record.flight_pid) {
    $flightProcess=Get-Process -Id $record.flight_pid -ErrorAction SilentlyContinue
    if ($flightProcess -and $flightProcess.Path -eq $record.flight_path) { Stop-Process -Id $flightProcess.Id; $flightProcess.WaitForExit(10000) | Out-Null; Write-Host 'Stopped the recorded background flight peer.' }
}
$engineProcess=Get-Process -Id $record.engine_pid -ErrorAction SilentlyContinue
if ($engineProcess -and $engineProcess.Path -eq $record.engine_path) {
    Stop-Process -Id $engineProcess.Id
    $engineProcess.WaitForExit(10000) | Out-Null
    Write-Host 'Stopped the demo engine. Stop the flight terminal with Ctrl+C.'
} else { Write-Host 'The recorded demo engine is already stopped.' }
