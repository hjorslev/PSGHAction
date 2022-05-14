$Lines = '-' * 70

Import-Module 'SteamPS'

$PesterVersion = (Get-Module -Name Pester).Version
$PSVersion = $PSVersionTable.PSVersion

Write-Host $Lines
Write-Host "TEST: PowerShell Version: $PSVersion"
Write-Host "TEST: Pester Version: $PesterVersion"
Write-Host $Lines

try {
    # Try/Finally required since -CI will exit with exit code on failure.
    Invoke-Pester -Path "$env:PROJECTROOT" -CI -Output Normal
} finally {
    $Timestamp = Get-Date -Format "yyyyMMdd-hhmmss"
    $TestFile = "PS${PSVersion}_${TimeStamp}_SteamPS.TestResults.xml"
    $CodeCoverageFile = "PS${PSVersion}_${TimeStamp}_SteamPS.CodeCoverage.xml"

    $ModuleFolders = @(
        Get-Item -Path "$env:PROJECTROOT/SteamPS"
        Get-ChildItem -Path "$env:PROJECTROOT/SteamPS" -Directory -Recurse |
        Where-Object FullName -NotMatch '[\\/]Tests[\\/]|[\\/]SteamPS[\\/]'
    ).FullName -join ';'

    $GithubActions = [bool]$env:GITHUB_WORKSPACE

    if ($GithubActions) {
        @(
            "TestResults=$TestFile"
            "CodeCoverageFile=$CodeCoverageFile"
            "SourceFolders=$ModuleFolders"
        ) | Add-Content -Path $env:GITHUB_ENV

        Move-Item -Path './testResults.xml' -Destination "$env:GITHUB_WORKSPACE/$TestFile"
        Move-Item -Path './coverage.xml' -Destination "$env:GITHUB_WORKSPACE/$CodeCoverageFile"
    }
}