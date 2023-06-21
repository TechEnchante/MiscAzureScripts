#!/bin/bash

# This script will create a resource group, a storage account, and a blob container. 
# Then it will upload a file to that blob container.

# Variables
resourceGroup="MyResourceGroup"
location="westus"
storageAccount="mystorageaccount$RANDOM"
containerName="myblobcontainer"

# Create a resource group
echo "Creating resource group..."
az group create --name $resourceGroup --location $location

# Create a storage account
echo "Creating storage account..."
az storage account create --name $storageAccount --resource-group $resourceGroup --location $location --sku Standard_RAGRS --kind StorageV2

# Get storage account key
echo "Getting storage account key..."
accountKey=$(az storage account keys list --resource-group $resourceGroup --account-name $storageAccount --query '[0].value' -o tsv)

# Create a blob container
echo "Creating blob container..."
az storage container create --name $containerName --account-name $storageAccount --account-key $accountKey

echo "Script completed."
