[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Organization,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $FeedId,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $GroupId,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ArtifactId,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Version,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
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
$uri = "https://pkgs.dev.azure.com/$Organization/_apis/packaging/feeds/$FeedId/maven/$GroupId/$ArtifactId/$Version/$FileName/content?api-version=7.0-preview.1"

Write-Host "Downloading Maven package from '$uri'..." -ForegroundColor Blue

Invoke-RestMethod -Method Get -Uri $uri -Headers @{ Authorization = "Bearer $token" } -OutFile "$OutputDirectory\$FileName"	

Write-Host "Done." -ForegroundColor Green
