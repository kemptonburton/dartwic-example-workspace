$ErrorActionPreference='Stop'
$repoPath=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$fixture=Join-Path ([IO.Path]::GetTempPath()) ("dartwic-flight-test-"+[Guid]::NewGuid())
$oldLocalData=$env:LOCALAPPDATA
$oldPassword=$env:DARTWIC_PASSWORD
function Assert-True($condition,$message) { if (!$condition) { throw $message } }
function Start-Process {
    param($FilePath,$ArgumentList,$WorkingDirectory,$WindowStyle,$RedirectStandardOutput,$RedirectStandardError,[switch]$PassThru)
    $global:FlightDemoTest.arguments=$ArgumentList
    $global:FlightDemoTest.started++
    $global:FlightDemoTest.process.Path=$FilePath
    return $global:FlightDemoTest.process
}
function Get-Process { param($Id,$ErrorAction) if ($global:FlightDemoTest.alive) { return $global:FlightDemoTest.process } }
function Stop-Process { param($Id,$ErrorAction) $global:FlightDemoTest.stopped++; $global:FlightDemoTest.alive=$false }
try {
    New-Item -ItemType Directory -Path $fixture | Out-Null
    $env:LOCALAPPDATA=Join-Path $fixture 'local'
    $executable=Join-Path $fixture 'rocket-flight-peer.exe'
    Set-Content -LiteralPath $executable -Value 'fixture'
    $process=[PSCustomObject]@{Id=123;Path=$executable;StartTime=[DateTime]::UtcNow}
    $process | Add-Member -MemberType ScriptMethod -Name WaitForExit -Value { param($timeout) return $true }
    $global:FlightDemoTest=@{process=$process;alive=$false;started=0;stopped=0;arguments=@()}
    . (Join-Path $repoPath 'tools/flight-demo-process.ps1')
    $state=Get-FlightDemoStatePath -RepositoryPath $repoPath
    Assert-True ($state.StartsWith($env:LOCALAPPDATA)) 'Flight state must be local application data.'
    Assert-True ($state -eq (Get-FlightDemoStatePath -RepositoryPath $repoPath)) 'Flight state must be stable.'
    $otherRepo=New-Item -ItemType Directory -Path (Join-Path $fixture 'other-clone')
    Assert-True ($state -ne (Get-FlightDemoStatePath -RepositoryPath $otherRepo.FullName)) 'Separate clones must be isolated.'
    & (Join-Path $repoPath 'tools/start-demo.ps1') -FlightExecutable $executable
    Assert-True ($global:FlightDemoTest.started -eq 1) 'The flight process must start once.'
    Assert-True (($global:FlightDemoTest.arguments -join ' ') -eq '--transport custom --receive-endpoint tcp://127.0.0.1:17601 --send-endpoint tcp://127.0.0.1:17600') 'Wrong custom flight arguments.'
    $global:FlightDemoTest.alive=$true
    $duplicateRejected=$false
    try { & (Join-Path $repoPath 'tools/start-demo.ps1') -FlightExecutable $executable } catch { $duplicateRejected=$_.Exception.Message -match 'already running' }
    Assert-True $duplicateRejected 'Duplicate launches must be rejected.'
    & (Join-Path $repoPath 'tools/stop-demo.ps1')
    Assert-True ($global:FlightDemoTest.stopped -eq 1) 'Only the matching flight process must stop.'
    & (Join-Path $repoPath 'tools/stop-demo.ps1')
    Assert-True ($global:FlightDemoTest.stopped -eq 1) 'Stopping twice must be harmless.'
    $env:DARTWIC_PASSWORD=$null
    $missingPasswordRejected=$false
    try { & (Join-Path $repoPath 'tools/start-demo.ps1') -FlightExecutable $executable -Transport native } catch { $missingPasswordRejected=$_.Exception.Message -match 'DARTWIC_PASSWORD' }
    Assert-True $missingPasswordRejected 'Native mode must require its existing password environment variable.'
    $env:DARTWIC_PASSWORD='fixture-only'
    & (Join-Path $repoPath 'tools/start-demo.ps1') -FlightExecutable $executable -Transport native -Port 7800
    Assert-True (($global:FlightDemoTest.arguments -join ' ') -eq '--transport native --host 127.0.0.1 --port 7800') 'Wrong native flight arguments.'
    $global:FlightDemoTest.alive=$true
    $recordPath=Join-Path $state 'process.json'
    $record=Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json
    $record.start_time_ticks='1'
    $record | ConvertTo-Json | Set-Content -LiteralPath $recordPath
    & (Join-Path $repoPath 'tools/stop-demo.ps1')
    Assert-True ($global:FlightDemoTest.stopped -eq 1) 'A reused PID must not be stopped.'
    Assert-True (!(Test-Path -LiteralPath (Join-Path $repoPath 'engine'))) 'The scripts must not create an engine directory.'
    Write-Host 'Flight-only startup, duplicate protection, shutdown, native arguments, and PID reuse checks passed.'
} finally {
    $env:LOCALAPPDATA=$oldLocalData
    $env:DARTWIC_PASSWORD=$oldPassword
    $resolved=[IO.Path]::GetFullPath($fixture)
    if ($resolved.StartsWith([IO.Path]::GetTempPath(),[StringComparison]::OrdinalIgnoreCase) -and (Split-Path $resolved -Leaf).StartsWith('dartwic-flight-test-')) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
