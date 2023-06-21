#!/bin/bash

# Prompt the user for various inputs
read -p "Enter your Azure subscription ID: " SUBSCRIPTION_ID
read -p "Enter the resource group name: " RESOURCE_GROUP
read -p "Enter the SQL Server name: " SQL_SERVER_NAME
read -p "Enter the SQL Server admin login: " SERVER_ADMIN_LOGIN
read -s -p "Enter the SQL Server admin password: " SERVER_ADMIN_PASSWORD
echo ""
read -p "Enter the database name: " DATABASE_NAME
read -p "Enter the table name: " TABLE_NAME
read -p "Enter the table schema (e.g., 'column1 datatype, column2 datatype'): " TABLE_SCHEMA
read -p "Enter the location (e.g., westus): " LOCATION
read -p "Enter the blob URL of the .csv file: " BLOB_URL

# Log in to Azure
az login

# Set the Azure subscription
az account set --subscription $SUBSCRIPTION_ID

# Create a SQL Server
az sql server create --name $SQL_SERVER_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --admin-user $SERVER_ADMIN_LOGIN --admin-password $SERVER_ADMIN_PASSWORD

# Create a SQL database
az sql db create --resource-group $RESOURCE_GROUP --server $SQL_SERVER_NAME --name $DATABASE_NAME --edition GeneralPurpose --family Gen5 --capacity 2

# Log in to the SQL Server
# Note: This is an example. You need to use a tool like sqlcmd or Azure Data Studio to execute these SQL commands.
# echo "Connecting to $SQL_SERVER_NAME.database.windows.net"
# sqlcmd -S $SQL_SERVER_NAME.database.windows.net -U $SERVER_ADMIN_LOGIN -P $SERVER_ADMIN_PASSWORD -d $DATABASE_NAME

# Create a table in the SQL database
# Note: This command is meant to be run on the SQL server itself, not from the bash shell.
echo "CREATE TABLE $TABLE_NAME ($TABLE_SCHEMA);"

# Use the BULK INSERT command to import the CSV file into the SQL table
# Note: This command is meant to be run on the SQL server itself, not from the bash shell.
echo "BULK INSERT $TABLE_NAME
FROM '$BLOB_URL'
WITH
(
  FORMAT = 'CSV'
);"
