<#
.SYNOPSIS
    Downloads files from Azure Blob Storage container while preserving folder hierarchy.

.DESCRIPTION
    This script connects to an Azure Blob Storage container and downloads all files
    to a specified local folder, maintaining the original blob folder structure.

.PARAMETER StorageAccountName
    The name of the Azure Storage Account.

.PARAMETER ContainerName
    The name of the blob container to download from.

.PARAMETER LocalPath
    The local directory path where files will be downloaded.

.PARAMETER StorageAccountKey
    The storage account access key (optional if using Azure CLI authentication).

.PARAMETER ConnectionString
    The complete connection string for the storage account (alternative to account name/key).

.EXAMPLE
    .\Get-AzureBlobFiles.ps1 -StorageAccountName "mystorageaccount" -ContainerName "mycontainer" -LocalPath "C:\Downloads"

.EXAMPLE
    .\Get-AzureBlobFiles.ps1 -ConnectionString "DefaultEndpointsProtocol=https;AccountName=..." -ContainerName "mycontainer" -LocalPath "C:\Downloads"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ParameterSetName = "AccountNameKey")]
    [string]$StorageAccountName,
    
    [Parameter(Mandatory = $true)]
    [string]$ContainerName,
    
    [Parameter(Mandatory = $true)]
    [string]$LocalPath,
    
    [Parameter(Mandatory = $false, ParameterSetName = "AccountNameKey")]
    [string]$StorageAccountKey,
    
    [Parameter(Mandatory = $true, ParameterSetName = "ConnectionString")]
    [string]$ConnectionString
)

# Import required modules
try {
    Import-Module Az.Storage -ErrorAction Stop
}
catch {
    Write-Error "Failed to import Az.Storage module. Please install it using: Install-Module -Name Az.Storage"
    exit 1
}

# Create local directory if it doesn't exist
if (-not (Test-Path -Path $LocalPath)) {
    try {
        New-Item -ItemType Directory -Path $LocalPath -Force | Out-Null
    }
    catch {
        Write-Error "Failed to create local directory: $LocalPath. Error: $_"
        exit 1
    }
}

# Create storage context
try {
    if ($PSCmdlet.ParameterSetName -eq "ConnectionString") {
        $storageContext = New-AzStorageContext -ConnectionString $ConnectionString
    }
    else {
        if ($StorageAccountKey) {
            $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
        }
        else {
            # Try to use Azure CLI or managed identity
            $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount
        }
    }
}
catch {
    Write-Error "Failed to create storage context. Error: $_"
    exit 1
}

# Get all blobs from the container
try {
    $blobs = Get-AzStorageBlob -Container $ContainerName -Context $storageContext
    $totalBlobs = $blobs.Count
    Write-Host "Found $totalBlobs files to download"
}
catch {
    Write-Error "Failed to retrieve blobs from container '$ContainerName'. Error: $_"
    exit 1
}

# Download each blob
$downloadedCount = 0
$errorCount = 0

foreach ($blob in $blobs) {
    try {
        # Create the full local file path, preserving directory structure
        $relativePath = $blob.Name
        $localFilePath = Join-Path -Path $LocalPath -ChildPath $relativePath
        
        # Create directory structure if it doesn't exist
        $localDirectory = Split-Path -Path $localFilePath -Parent
        if (-not (Test-Path -Path $localDirectory)) {
            New-Item -ItemType Directory -Path $localDirectory -Force | Out-Null
        }
        
        # Download the blob
        Get-AzStorageBlobContent -Blob $blob.Name -Container $ContainerName -Destination $localFilePath -Context $storageContext -Force | Out-Null
        
        $downloadedCount++
    }
    catch {
        Write-Warning "Failed to download blob '$($blob.Name)': $_"
        $errorCount++
    }
}

# Summary
Write-Host "Downloaded $downloadedCount of $totalBlobs files to $LocalPath"

if ($errorCount -gt 0) {
    Write-Host "$errorCount files failed to download" -ForegroundColor Yellow
}
