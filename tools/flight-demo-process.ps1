function Get-FlightDemoStatePath {
    param([Parameter(Mandatory=$true)][string]$RepositoryPath)
    $repo=(Resolve-Path -LiteralPath $RepositoryPath).Path
    $localData=$env:LOCALAPPDATA
    if (!$localData) { $localData=[Environment]::GetFolderPath('LocalApplicationData') }
    if (!$localData) { throw 'Local application data is unavailable.' }
    # Process records and logs are local; separate clones manage separate flight peers.
    $sha=[Security.Cryptography.SHA256]::Create()
    try { $hash=[BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($repo.ToLowerInvariant()))).Replace('-','').Substring(0,12).ToLowerInvariant() }
    finally { $sha.Dispose() }
    $state=[IO.Path]::GetFullPath((Join-Path $localData "DARTWIC Flight Demo/$hash"))
    if ($state.StartsWith($repo+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Flight process records must be stored outside this repository.' }
    return $state
}

function Get-RecordedFlightDemoProcess {
    param([Parameter(Mandatory=$true)][string]$RecordPath)
    if (!(Test-Path -LiteralPath $RecordPath)) { return $null }
    $record=Get-Content -LiteralPath $RecordPath -Raw | ConvertFrom-Json
    if (!$record.pid -or !$record.executable -or !$record.start_time_ticks) { throw 'Invalid flight demo process record.' }
    $process=Get-Process -Id $record.pid -ErrorAction SilentlyContinue
    if ($process -and $process.Path -eq $record.executable -and "$($process.StartTime.ToUniversalTime().Ticks)" -eq $record.start_time_ticks) { return $process }
    return $null
}
