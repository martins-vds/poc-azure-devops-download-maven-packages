# Proof of Concept - How to download Maven packages from Azure Artifacts using Powershell

## Prerequisites

- [Powershell 7.3](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3)

### Description

This PowerShell script is used to perform an action on an artifact in Azure DevOps Package Management. It requires various parameters to be provided, such as organization, project ID, feed ID, group ID, artifact ID, version, file name, output directory, token, server URL, and API version.

### Syntax

```powershell
.\Download-MavenPackage.ps1 -Organization <string> -ProjectId <string> -FeedId <string> -GroupId <string> -ArtifactId <string> -Version <string> -FileName <string> -OutputDirectory <System.IO.FileInfo> [-Token <string>] [-ServerUrl <string>] [-ApiVersion <string>]
```

### Parameters

- `-Organization <string>` (Mandatory): Specifies the Azure DevOps organization.
- `-ProjectId <string>` (Optional): Specifies the ID of the project. If not provided, the default project will be used.
- `-FeedId <string>` (Mandatory): Specifies the ID of the feed in Azure DevOps Package Management.
- `-GroupId <string>` (Mandatory): Specifies the ID of the group containing the artifact.
- `-ArtifactId <string>` (Mandatory): Specifies the ID of the artifact.
- `-Version <string>` (Mandatory): Specifies the version of the artifact.
- `-FileName <string>` (Mandatory): Specifies the name of the file.
- `-OutputDirectory <System.IO.FileInfo>` (Mandatory): Specifies the output directory where the file will be saved.
- `-Token <string>` (Optional): Specifies the authentication token for accessing Azure DevOps. If not provided, the default token will be used.
- `-ServerUrl <string>` (Optional): Specifies the URL of the Azure DevOps server. If not provided, the default server URL will be used.
- `-ApiVersion <string>` (Optional): Specifies the version of the Azure DevOps API to use. Possible values are "5.1-preview.1", "6.0-preview.1", or "7.0-preview.1". If not provided, the default API version "7.0-preview.1" will be used.

### Example Usage

```powershell
.\Download-MavenPackage.ps1 -Organization "exampleorg" -FeedId "feed1" -GroupId "group1" -ArtifactId "artifact1" -Version "1.0.0" -FileName "file.txt" -OutputDirectory "C:\Output" -Token "your_token" -ServerUrl "https://pkgs.dev.azure.com" -ApiVersion "7.0-preview.1"
```

### Notes

- The script requires appropriate access permissions to perform the specified action on the Azure DevOps Package Management artifacts.
- Make sure to provide the correct values for the parameters to ensure successful execution.
- If the `ProjectId` parameter is not provided, the script will use the default project associated with the organization.
- The `Token` parameter is used for authentication. If not provided, the script will use the default token.
- The `ServerUrl` parameter specifies the URL of the Azure DevOps server. If not provided, the default server URL ("<https://pkgs.dev.azure.com>") will be used.
- The `ApiVersion` parameter specifies the version of the Azure DevOps API to use. If not provided, the default API version "7.0-preview.1" will be used.
