properties {
    $buildNumber = $null
    $tag = $null

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

function UpdateVersionVariables ()
{
    $script:versionSuffix = $null
    $script:versionTag = $null
    If ($buildNumber)
    {
        $script:versionSuffix = "build-" + $buildNumber.ToString().PadLeft(5,'0');
    }
    else 
    {
        If ($tag)
        {
            $script:versionTag = $tag.Replace("release-", "").Replace("v.", "").Replace("v", "");

            $projectVersion = ((Get-Content $project) -Join "`n" | ConvertFrom-Json).version;
            If ($versionTag -ne $projectVersion -and ($versionTag + "-*") -ne $projectVersion)
            {
                $nl = [Environment]::NewLine
                throw "git tag is $tag , but version property in project.json is $projectVersion. $nl
  Please update project version to $versionTag or $versionTag-* before tagging. $nl
    You might also need to delete your tag: $nl
    > git tag -d $tag $nl
    > git push origin :refs/tags/$tag"
            }
        }
        else
        {
            throw "buildNumber or tag should be specified"
        }
    }
}

TaskSetup {
    $script:ArtifactoryApiKey = $ArtifactoryUserName + ":" + $ArtifactoryPassword
}

Task SetupArtifactory -description "Add Artifactory to nuget" `
{
}

Task PushNuget -depends Pack, SetupArtifactory -description "Push NuGet package to artifactory" {
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
    UpdateVersionVariables

    If ($versionSuffix)
    {
        Exec -cmd { dotnet build $project --version-suffix $versionSuffix }
    }
    else
    {
        Exec -cmd { dotnet build $project }
    }
}

Task UnitTest -depends Build -description "Runs unit tests" {
    Test-Projects $unitTestsProject
}

Task Pack -depends Build {
    UpdateVersionVariables

    If ($versionSuffix)
    {
        Exec -cmd { dotnet pack $project -o .\pack --no-build --version-suffix $versionSuffix }

        Write-Output "versionSuffix $versionSuffix"
    }
    else
    {
        Exec -cmd { dotnet pack $project -o .\pack --no-build }

        Write-Output "versionTag $versionTag"
    }
}
