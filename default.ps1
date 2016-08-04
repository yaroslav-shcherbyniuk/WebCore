properties {
    $buildNumber = 0

    $project = ".\src\ClassLibrary1\project.json"
    $unitTestsProject = ".\test\TestClassLibrary1\project.json"

    $ArtifactoryUserName = $null
    $ArtifactoryPassword = $null
    $ArtifactorySource = "https://artifactory.dev.ipreo.com/artifactory/api/nuget/nuget-repo"
    $ArtifactoryFolder = "/IpreoAccount/IpreoAccount.Common"
}

function Restore-Packages ([string] $DirectoryName)
{
    Exec -cmd { & dotnet restore ("""" + $DirectoryName + """") --source "https://www.nuget.org/api/v2/" }
}

function Test-Projects ([string] $Project)
{
    Write-Output "Testing Project: $Project"
    $ProjectFolder= Split-Path $Project
    Push-Location $ProjectFolder
    Exec -cmd { & dotnet test; }
    Pop-Location
}

TaskSetup {
    $script:versionSuffix = "build-" + $buildNumber.ToString().PadLeft(5,'0');
    $script:ArtifactoryApiKey = $ArtifactoryUserName + ":" + $ArtifactoryPassword
}

Task SetupArtifactory -description "Add Artifactory to nuget" `
    -requiredVariables ArtifactoryUserName, ArtifactoryPassword `
{

    Assert $ArtifactoryUserName "Please provide ArtifactoryUserName property."
    Assert $ArtifactoryPassword "Please provide ArtifactoryPassword property."

    try
    {
        nuget sources Remove -Name Artifactory
    }
    catch
    {
        Write-Output $_.Exception.Message
    }

    Exec -cmd { nuget sources Add -Name Artifactory -Source $ArtifactorySource -UserName $ArtifactoryUserName -Password $ArtifactoryPassword -StorePasswordInClearText }
}

Task PushNuget -depends Pack, SetupArtifactory -description "Push NuGet package to artifactory" {

    $symboldNuget = (Get-ChildItem ".\pack" | ? {$_.Name -match '.symbols.nupkg$'}).Name

    Exec -cmd { nuget push ".\pack\$symboldNuget" -Source $ArtifactorySource$ArtifactoryFolder -ApiKey $ArtifactoryApiKey }
}

Task Clean -description "Deletes all bin folders" {

    Get-ChildItem $PWD -recurse |
        ? {$_.Attributes -eq 'Directory' -and  $_.Name -like 'bin'} | 
        % { Remove-Item $_.FullName -Force -Recurse }

    try
    {
        Remove-Item .\publish -Force -Recurse
    }
    catch [System.Management.Automation.ItemNotFoundException]
    {
        #if the script hasn't run before, the publish directory won't exist
        Write-Output $_.Exception.Message
    }

    try
    {
        Remove-Item .\pack -Force -Recurse
    }
    catch [System.Management.Automation.ItemNotFoundException]
    {
        #if the script hasn't run before, the publish directory won't exist
        Write-Output $_.Exception.Message
    }
}

Task Restore -description "Restores packages for all projects" {
    Restore-Packages (Get-Item -Path ".\" -Verbose).FullName
}

Task Build -depends Restore -description "Build project" {
    Exec -cmd { dotnet build $project }
}

Task UnitTest -depends Build -description "Runs unit tests" {
    Test-Projects $unitTestsProject
}

Task Pack -depends Build {
    Exec -cmd { dotnet pack $project -o .\pack  }
}
