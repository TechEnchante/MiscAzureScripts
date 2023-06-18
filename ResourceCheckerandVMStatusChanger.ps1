# Import necessary modules
Import-Module Az.Accounts
Import-Module Az.Compute
Import-Module Az.Resources

# Login to Azure account
Login-AzAccount

# Function to get resources by subscription
function Get-ResourcesBySubscription ($subscriptionId) {
    try {
        Set-AzContext -SubscriptionId $subscriptionId -ErrorAction Stop
    } catch {
        Write-Host "Error: Unable to set context with provided Subscription ID"
        return
    }

    $resources = Get-AzResource
    $output = @()

    foreach($resource in $resources){
        $resourceObj = New-Object PSObject -Property @{
            ResourceType = $resource.ResourceType
            Name = $resource.Name
            Location = $resource.Location
            ResourceGroupName = $resource.ResourceGroupName
            ProvisioningState = $resource.ProvisioningState
            Tags = $resource.Tags
        }

        $output += $resourceObj
    }

    $output | Format-Table -AutoSize

    # Display VM statuses
    Get-AzVM | ForEach-Object { 
        $vmStatus = Get-AzVM -ResourceGroupName $_.ResourceGroupName -Name $_.Name -Status
        Write-Host "$($_.Name) VM status: $($vmStatus.Statuses.Code)"
    }

    # Display AKS status
    $aksClusters = az aks list --subscription $subscriptionId | ConvertFrom-Json
    foreach ($cluster in $aksClusters) {
        Write-Host "AKS Cluster $($cluster.name) status: $($cluster.provisioningState)"
    }

    # Display Usage
    $usages = Get-AzVMUsage -Location "East US"
    foreach($usage in $usages){
        Write-Host "Usage $($usage.Name.LocalizedValue): Limit - $($usage.Limit), Current Value - $($usage.CurrentValue)"
    }
}

# Function to start VM with confirmation
function Start-VMWithConfirm ($resourceGroupName, $vmName) {
    try {
        $vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -ErrorAction Stop
        if ($vm) {
            $userConfirm = Read-Host "Are you sure you want to start VM $vmName in resource group $resourceGroupName? (y/n)"
            if ($userConfirm -eq 'y' -or $userConfirm -eq 'Y') {
                Start-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
            }
        }
    } catch {
        Write-Host "Error: VM $vmName not found in resource group $resourceGroupName"
    }
}

# Function to stop VM with confirmation
function Stop-VMWithConfirm ($resourceGroupName, $vmName) {
    try {
        $vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -ErrorAction Stop
        if ($vm) {
            $userConfirm = Read-Host "Are you sure you want to stop VM $vmName in resource group $resourceGroupName? (y/n)"
            if ($userConfirm -eq 'y' -or $userConfirm -eq 'Y') {
                Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
            }
        }
    } catch {
        Write-Host "Error: VM $vmName not found in resource group $resourceGroupName"
    }
}

# Main script
$checkOption = Read-Host -Prompt 'Do you want to check by (1) Subscription, (2) Resource Group, or (3) Tag? Or do you want to (4) Start a VM, (5) Stop a VM or (6) List VMs? Enter the corresponding number'

switch ($checkOption) {
    1 {
        $subscriptionId = Read-Host -Prompt 'Enter Subscription ID'
        Get-ResourcesBySubscription $subscriptionId
    }
    2 {
        $resourceGroupName = Read-Host -Prompt 'Enter Resource Group Name'
        Get-ResourcesByResourceGroup $resourceGroupName
    }
    3 {
        $tagName = Read-Host -Prompt 'Enter Tag Name'
        $tagValue = Read-Host -Prompt 'Enter Tag Value'
        Get-ResourcesByTag $tagName $tagValue
    }
    4 {
        $resourceGroupName = Read-Host -Prompt 'Enter Resource Group Name for VM to start'
        $vmName = Read-Host -Prompt 'Enter VM Name to start'
        Start-VMWithConfirm $resourceGroupName $vmName
    }
    5 {
        $resourceGroupName = Read-Host -Prompt 'Enter Resource Group Name for VM to stop'
        $vmName = Read-Host -Prompt 'Enter VM Name to stop'
        Stop-VMWithConfirm $resourceGroupName $vmName
    }
    6 {
        List-VMs
    }
    default {
        Write-Host 'Invalid option selected'
    }
}
