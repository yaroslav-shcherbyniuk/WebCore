Param(
    [int]$buildNumber = $env:BUILD_NUMBER,
    [string]$http_proxy = $env:http_proxy,

    [string]$ArtifactoryUserName = $env:ArtifactoryUserName,
    [string]$ArtifactoryPassword = $env:ArtifactoryPassword
)

.\InstallTools.ps1 -proxyAddress $http_proxy

Invoke-Psake -taskList Clean, UnitTest, Pack, SetupArtifactory, PushNuget -properties @{
    buildNumber=$buildNumber;

    ArtifactoryUserName=$ArtifactoryUserName;
    ArtifactoryPassword=$ArtifactoryPassword;
}

if ($psake.build_success -eq $false) { exit 1 } else { exit 0 }