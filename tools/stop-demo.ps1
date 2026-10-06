$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'flight-demo-process.ps1')
$repoPath=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$recordPath=Join-Path (Get-FlightDemoStatePath -RepositoryPath $repoPath) 'process.json'
$flightProcess=Get-RecordedFlightDemoProcess -RecordPath $recordPath
if ($flightProcess) {
    Stop-Process -Id $flightProcess.Id -ErrorAction Stop
    if (!$flightProcess.WaitForExit(10000)) { throw 'The flight demo did not exit within 10 seconds.' }
    Write-Host 'Stopped the flight demo.'
} else { Write-Host 'The recorded flight demo is already stopped or its PID belongs to another process.' }
if (Test-Path -LiteralPath $recordPath) { Remove-Item -LiteralPath $recordPath }
