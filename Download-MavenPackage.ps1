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
    [System.IO.FileInfo]
    $OutputDirectory,
    [Parameter(Mandatory = $false)]
    [string]
    $Token,
    [Parameter(Mandatory = $false)]
    [ValidatePattern("^(?<protocol>http(s)?)://(?<instance>[^/$]+(/[^/]+)*)(?<ending_slash>/?)|(?<empty_url>)$")]
    [string]
    $ServerUrl
)

function EncodeBase64 ($text) {
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($text)
    $base64 = [System.Convert]::ToBase64String($bytes)
    return $base64
}

function GetAccessTokenOrFallback ($token, $fallback) {
    if (![string]::IsNullOrEmpty($token)) {
        return "Basic $(EncodeBase64 ":$token")"
    }
    
    if (![string]::IsNullOrEmpty($fallback)) {
        return "Bearer $fallback"
    }

    throw "Access token is missing. Either provide it through the '-Token' parameter or create the environment variable 'SYSTEM_ACCESSTOKEN'"
}

function EnsureOutputDirectoryExists ($outputDirectory) {
    if (-Not (Test-Path $outputDirectory)) {
        New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null
    }
}

function ParseErrorMessage ($err) {
    return $err | ConvertFrom-Json | Select-Object -ExpandProperty message
}

function GetServerUrlOrFallback ($serverUrl, $fallback) {
    $urlPattern = "^(?<protocol>http(s)?)://(?<instance>[^/$]+(/[^/]+)*)(?<ending_slash>/?)|(?<empty_url>)$"

    if ([string]::IsNullOrEmpty($serverUrl)) {
        return $fallback
    }
    
    $serverUrl = $serverUrl.TrimEnd('/')
    
    $serverUrl -match $urlPattern | Out-Null

    $protocol = $Matches['protocol']
    $instance = $Matches['instance']

    return "$($protocol)://$($instance)"
}

$ErrorActionPreference = "Stop"

$token = GetAccessTokenOrFallback $Token $env:SYSTEM_ACCESSTOKEN
$uri = "$(GetServerUrlOrFallback $ServerUrl "https://pkgs.dev.azure.com")/$Organization/_apis/packaging/feeds/$FeedId/maven/$GroupId/$ArtifactId/$Version/$FileName/content?api-version=7.0-preview.1"

EnsureOutputDirectoryExists $OutputDirectory

Write-Host "Downloading file '$FileName' from Maven package '$($GroupId)/$($ArtifactId)'..." -ForegroundColor Blue

try {
    Write-Verbose "Requesting '$uri' with token '$token'..."

    Invoke-RestMethod -Method Get -Uri $uri -Headers @{ Authorization = $token } -OutFile "$OutputDirectory\$FileName"
    Write-Host "Successfully downloaded file '$FileName' to directory '$OutputDirectory'." -ForegroundColor Green
}
catch [Microsoft.PowerShell.Commands.HttpResponseException] {
    Write-Host "Failed to download file '$FileName' from Maven package '$($GroupId)/$($ArtifactId)'. Reason: $(ParseErrorMessage $_.ErrorDetails.Message)" -ForegroundColor Red
    exit 1
}