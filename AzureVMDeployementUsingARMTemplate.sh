#!/bin/bash


# Script Name: Azure VM Deployment
# Author: Adam Roberts
# Date: Created 06/18/2023
# Description: This script deploys a number of VMs in Azure using an ARM template and parameters file.

# Prompt the user for the number of VMs to deploy
read -p "Enter the number of VMs to be deployed: " num_vms

# Prompt the user for the resource group where the VMs should be deployed
read -p "Enter the resource group: " resource_group

# Prompt the user for the location of the ARM template file
read -p "Enter the location of the ARM template file: " template_file

# Prompt the user for the location of the parameters file
read -p "Enter the location of the parameters file: " parameters_file

# Provide a summary of the deployment details to the user
echo "You are about to deploy $num_vms VM(s) to the $resource_group resource group using the following files:"
echo "Template: $template_file"
echo "Parameters: $parameters_file"

# Ask the user to confirm the deployment
read -p "Are you sure you want to proceed? (y/n): " confirm

# Check if the user has confirmed the deployment
if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then

    # Loop over the number of VMs to deploy
    for ((i=1; i<=$num_vms; i++))
    do
        # Print a message about the current VM deployment
        echo "Deploying VM number $i"
        
        # Deploy the VM using the Azure CLI, the specified ARM template, parameters file and resource group
        az deployment group create --name ExampleDeployment$i --resource-group $resource_group --template-file $template_file --parameters @$parameters_file
        
        # Print a message indicating the VM deployment has finished
        echo "VM $i deployed"
    done
else
    # Print a message indicating the deployment has been cancelled
    echo "Deployment cancelled."
fi
