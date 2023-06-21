# Prompt the user to log into the subscription
$subscriptionId = Read-Host -Prompt "Enter the subscription ID"

# Sign in to Azure
Connect-AzAccount -SubscriptionId $subscriptionId

# Select a resource group
$resourceGroup = Read-Host -Prompt "Enter the name of the resource group"

# Select a storage account
$storageAccount = Read-Host -Prompt "Enter the name of the storage account"

# Select a blob container
$containerName = Read-Host -Prompt "Enter the name of the blob container"

# Select whether to upload a folder or a file
$uploadType = Read-Host -Prompt "Enter 'F' to upload a folder or 'S' to upload a single file"

if ($uploadType -eq 'F') {
    # Select the folder to upload
    $folderToUpload = Read-Host -Prompt "Enter the path of the local folder to upload"

    # Get the storage account key
    $storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -AccountName $storageAccount).Value[0]

    # Upload the folder to the blob container
    $context = New-AzStorageContext -StorageAccountName $storageAccount -StorageAccountKey $storageAccountKey
    Get-ChildItem -Path $folderToUpload -Recurse | ForEach-Object {
        $destinationPath = $_.FullName.Replace($folderToUpload, '')
        $destinationPath = $destinationPath -replace "^\\", ""
        Set-AzStorageBlobContent -Context $context -Container $containerName -File $_.FullName -Blob $destinationPath
    }

    Write-Host "Folder uploaded successfully."
}
elseif ($uploadType -eq 'S') {
    # Select the file to upload
    $fileToUpload = Read-Host -Prompt "Enter the path of the local file to upload"

    # Get the storage account key
    $storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -AccountName $storageAccount).Value[0]

    # Upload the file to the blob container
    $context = New-AzStorageContext -StorageAccountName $storageAccount -StorageAccountKey $storageAccountKey
    Set-AzStorageBlobContent -Context $context -Container $containerName -File $fileToUpload -Blob $(Split-Path $fileToUpload -Leaf)

    Write-Host "File uploaded successfully."
}
else {
    Write-Host "Invalid input. Please enter 'F' to upload a folder or 'S' to upload a single file."
}

# Prompt the user to save the settings to a new script
$saveSettings = Read-Host -Prompt "Do you want to save the settings to a new script? (Y/N)"

if ($saveSettings -eq 'Y') {
    $scriptName = Read-Host -Prompt "Enter a name for the new script (without the .ps1 extension)"

    $scriptContent = @"
# Select a subscription
`$subscriptionId = '$subscriptionId'

# Sign in to Azure
Connect-AzAccount -SubscriptionId `$subscriptionId

# Select a resource group
`$resourceGroup = '$resourceGroup'

# Select a storage account
`$storageAccount = '$storageAccount'

# Select a blob container
`$containerName = '$containerName'

# Select whether to upload a folder or a file
`$uploadType = '$uploadType'

# Set the file/folder path based on the upload type
`$fileToUpload = ""
`$folderToUpload = ""

if (`$uploadType -eq 'F') {
    `$folderToUpload = '$folderToUpload'
}
elseif (`$uploadType -eq 'S') {
    `$fileToUpload = '$fileToUpload'
}

# Get the storage account key
`$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName `$resourceGroup -AccountName `$storageAccount).Value[0]

# Upload the file or folder to the blob container
`$context = New-AzStorageContext -StorageAccountName `$storageAccount -StorageAccountKey `$storageAccountKey

if (`$uploadType -eq 'F') {
    Get-ChildItem -Path `$folderToUpload -Recurse | ForEach-Object {
        `$destinationPath = `$_.FullName.Replace(`$folderToUpload, '')
        `$destinationPath = `$destinationPath -replace "^\\", ""
        Set-AzStorageBlobContent -Context `$context -Container `$containerName -File `$_.FullName -Blob `$destinationPath
    }
    Write-Host "Folder uploaded successfully."
}
elseif (`$uploadType -eq 'S') {
    Set-AzStorageBlobContent -Context `$context -Container `$containerName -File `$fileToUpload -Blob `$((Split-Path `$fileToUpload -Leaf))
    Write-Host "File uploaded successfully."
}
else {
    Write-Host "Invalid input. Please enter 'F' to upload a folder or 'S' to upload a single file."
}
"@

    $scriptPath = Join-Path -Path (Get-Location) -ChildPath "$scriptName.ps1"
    $scriptContent | Out-File -FilePath $scriptPath -Encoding ASCII

    Write-Host "Settings saved to '$scriptPath'."
}
