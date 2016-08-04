Param(
    [string]$proxyAddress = "http://nyproxy.ideal.corp.local:8080/"
)

$PSScriptRoot = split-path -parent $MyInvocation.MyCommand.Definition;
$TOOLS_DIR = Join-Path $PSScriptRoot "tools"
$NUGET_EXE = Join-Path $TOOLS_DIR "nuget.exe"
$PSAKE_MODULE = Join-Path $TOOLS_DIR "psake\tools\psake.psm1"
$NUGET_URL = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"

$wc = New-Object System.Net.WebClient

If($proxyAddress -ne "")
{
    $proxy = new-object System.Net.WebProxy
    $proxy.Address = (New-Object System.Uri -ArgumentList "http://nyproxy.ideal.corp.local:8080/")
    $proxy.credentials = [System.Net.CredentialCache]::DefaultCredentials
    $wc.Proxy = $proxy
}

# Try download NuGet.exe if do not exist.
if (!(Test-Path $NUGET_EXE)) {
    $wc.DownloadFile($NUGET_URL, $NUGET_EXE)
    $env:Path += ";$TOOLS_DIR"

    Write-Output "nuget.exe has been downloaded."
}

# Make sure NuGet exists where we expect it.
if (!(Test-Path $NUGET_EXE)) {
    Throw "Could not find NuGet.exe"
}

# Restore tools from NuGet?
if(-Not $SkipToolPackageRestore.IsPresent)
{
    Push-Location
    Set-Location $TOOLS_DIR
    Invoke-Expression "$NUGET_EXE install -ExcludeVersion"
    Pop-Location
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    Write-Output "Tools have been restored."
}

# Make sure Psake exists where we expect it.
if (!(Test-Path $PSAKE_MODULE)) {
    Throw "Could not find psake module"
}

# Add psake module
Import-Module $PSAKE_MODULE

$psake.use_exit_on_error = $true