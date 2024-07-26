# List of required Azure CLI extensions
$extensions = @(
    "application-insights",
    "account",
    "aks-preview",
    "azure-devops",
    "container",
    "databricks",
    "eventgrid",
    "find",
    "interactive",
    "log-analytics",
    "resource-graph",
    "virtual-wan",
    "front-door",
    "webapp",
    "azure-firewall"
)

# Loop through each extension and install it
foreach ($extension in $extensions) {
    az extension add --name $extension
}

# Set the subscription ID and resource group name
$subscriptionId = "86efc65b-4bd2-4a22-800e-5bff2c0a2349"
$resourceGroupName = "YouMatterRG"
$location = "EastUS"

# Set the Bicep file paths
$appInsightsBicep = "./appInsights.bicep"
$keyVaultBicep = "./keyVault.bicep"
$virtualMachineBicep = "./virtualMachine.bicep"
$publicIpBicep = "./publicIp.bicep"
$vnetBicep = "./vnet.bicep"
$storageAccountBicep = "./storageAccount.bicep"

# Parameters for Key Vault
$keyVaultParams = @{
    keyVaultName = "YouMatterKV"
    location = $location
    objectId = "87dfdafe-e445-4b3a-b8f9-d3cb4eba5f87"
}

# Parameters for Application Insights
$appInsightsParams = @{
    appInsightsName = "YouMatterAI"
    location = $location
}

# Parameters for Virtual Machine
$vmParams = @{
    vmName = "YourVMName"
    location = $location
    vmSize = "Standard_DS2_v2"
    adminUsername = "YourAdminUsername"
    adminPassword = (ConvertTo-SecureString -String "YourAdminPassword" -AsPlainText -Force)
    subnetId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/virtualNetworks/YouMatterVnet/subnets/YourSubnetName"
    networkInterfaceName = "YourNetworkInterfaceName"
    publicIpName = "YourPublicIpName"
    diskName = "YourDiskName"
}

# Parameters for Public IP
$publicIpParams = @{
    publicIpName = "YouMatterPIP"
    location = $location
}

# Parameters for Virtual Network
$vnetParams = @{
    vnetName = "YouMatterVnet"
    location = $location
    addressPrefixes = @("10.0.0.0/16")
    subnetName = "YourSubnetName"
    subnetPrefix = "10.0.1.0/24"
}

# Parameters for Storage Account
$storageAccountParams = @{
    storageAccountName = "YourStorageAccountName"
    location = $location
}

# Create Resource Group
try {
    az group create --name $resourceGroupName --location $location --subscription $subscriptionId
    Write-Host "Resource group '$resourceGroupName' created successfully."
} catch {
    Write-Error "Failed to create resource group '$resourceGroupName'."
    exit 1
}

# az ad sp create-for-rbac --name "YouMatter" 
#az role assignment create --assignee 87dfdafe-e445-4b3a-b8f9-d3cb4eba5f87 --role Contributor --scope /subscriptions/86efc65b-4bd2-4a22-800e-5bff2c0a2349/resourceGroups/YouMatterRG
#az role assignment list --assignee 87dfdafe-e445-4b3a-b8f9-d3cb4eba5f87 --scope /subscriptions/86efc65b-4bd2-4a22-800e-5bff2c0a2349/resourceGroups/YouMatterRG --output table


# Deploy Key Vault
try {
    az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $keyVaultBicep --parameters $keyVaultParams --debug
    Write-Host "Key Vault deployed successfully."
} catch {
    Write-Error "Failed to deploy Key Vault."
}

# Deploy Application Insights
try {
    az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $appInsightsBicep --parameters $appInsightsParams
    Write-Host "Application Insights deployed successfully."
} catch {
    Write-Error "Failed to deploy Application Insights."
}

# Deploy Public IP
try {
    az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $publicIpBicep --parameters $publicIpParams
    Write-Host "Public IP deployed successfully."
} catch {
    Write-Error "Failed to deploy Public IP."
}

# Deploy Virtual Network
try {
    az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $vnetBicep --parameters $vnetParams
    Write-Host "Virtual Network deployed successfully."
} catch {
    Write-Error "Failed to deploy Virtual Network."
}

# Deploy Storage Account
try {
    az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $storageAccountBicep --parameters $storageAccountParams
    Write-Host "Storage Account deployed successfully."
} catch {
    Write-Error "Failed to deploy Storage Account."
}

# Deploy Virtual Machine
try {
    az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $virtualMachineBicep --parameters $vmParams
    Write-Host "Virtual Machine deployed successfully."
} catch {
    Write-Error "Failed to deploy Virtual Machine."
}
