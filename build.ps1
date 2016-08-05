Param(
    [int]$buildNumber = $null,
    [string]$tag = $null,
    [string]$http_proxy = $env:http_proxy,

    [string]$ArtifactoryUserName = $env:ArtifactoryUserName,
    [string]$ArtifactoryPassword = $env:ArtifactoryPassword
)

.\InstallTools.ps1 -proxyAddress $http_proxy

Assert ($buildNumber -or $tag) "buildNumber or tag should be specified"

Invoke-Psake -taskList Clean, UnitTest, Pack, SetupArtifactory, PushNuget -properties @{
    buildNumber=$buildNumber;

    ArtifactoryUserName=$ArtifactoryUserName;
    ArtifactoryPassword=$ArtifactoryPassword;
}

#if ($psake.build_success -eq $false) { exit 1 } else { exit 0 }
