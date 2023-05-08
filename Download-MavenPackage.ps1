[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Project,
    [Parameter(Mandatory)]
    [string]
    $FeedId,
    [Parameter(Mandatory)]
    [string]
    $GroupId,
    [Parameter(Mandatory)]
    [string]
    $ArtifactId,
    [Parameter(Mandatory)]
    [string]
    $Version,
    [Parameter(Mandatory)]
    [string]
    $FileName,
    [Parameter(Mandatory)]
    [ValidateScript({
        if (-Not ($_ | Test-Path) ) {
            throw "File or folder does not exist"
        }

        if (-Not ($_ | Test-Path -PathType Container) ) {
            throw "The OutputDirectory argument must be a folder. File paths are not allowed."
        }

        return $true 
    })]
    [System.IO.FileInfo]
    $OutputDirectory
)

function GetAccessToken () {    
    if (![string]::IsNullOrEmpty($env:SYSTEM_ACCESSTOKEN)) {
        return $env:SYSTEM_ACCESSTOKEN
    }

    throw "The environment variable SYSTEM_ACCESSTOKEN is missing. This variable is required to authenticate with Azure DevOps. Please make sure it is defined."
}

$ErrorActionPreference = "Stop"

$token = GetAccessToken
$uri = "https://pkgs.dev.azure.com/$Project/_apis/packaging/feeds/$FeedId/maven/packages/$GroupId/$ArtifactId/versions/$Version/content?api-version=5.1-preview.1"

Invoke-RestMethod -Method Get -Uri $uri -Headers @{ Authorization = "Bearer $token" } -OutFile "$OutputDirectory\$FileName"	