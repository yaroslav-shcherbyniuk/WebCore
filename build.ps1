Param(
    [string]$buildNumber = $null,
    [string]$tag = $null,
    [string]$http_proxy = $env:http_proxy,

    [string]$ArtifactoryUserName = $env:ArtifactoryUserName,
    [string]$ArtifactoryPassword = $env:ArtifactoryPassword
)

.\InstallTools.ps1 -proxyAddress $http_proxy

Invoke-Psake -taskList Clean, UnitTest, Pack, SetupArtifactory, PushNuget -properties @{
    buildNumber=$buildNumber;
    tag=$tag;

    ArtifactoryUserName=$ArtifactoryUserName;
    ArtifactoryPassword=$ArtifactoryPassword;
}