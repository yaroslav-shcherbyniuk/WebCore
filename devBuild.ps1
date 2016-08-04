Param(
    [int]$buildNumber = 5
)

.\InstallTools.ps1 -proxyAddress ""

Invoke-Psake -taskList Clean, UnitTest, Pack -properties @{
    buildNumber=$buildNumber;
}
