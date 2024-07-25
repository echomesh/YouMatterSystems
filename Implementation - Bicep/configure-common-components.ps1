# Set the subscription ID and resource group name
$subscriptionId = "83254ae3-02c7-4dcf-b4bd-77183d0ff603"
$resourceGroupName = "YouMatter"
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
    keyVaultName = "YouMatterKeyVault"
    location = $location
    objectId = "98049e66-ff3b-40fd-9586-f9dfde618805"
}


# Parameters for Virtual Machine
$vmParams = @{
    vmName = "YourVMName"
    location = $location
    vmSize = "Standard_DS2_v2"
    adminUsername = "YourAdminUsername"
    adminPassword = (ConvertTo-SecureString -String "YourAdminPassword" -AsPlainText -Force)
    subnetId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/virtualNetworks/YourVnetName/subnets/YourSubnetName"
    networkInterfaceName = "YourNetworkInterfaceName"
    publicIpName = "YourPublicIpName"
    diskName = "YourDiskName"
}

# Parameters for Public IP
$publicIpParams = @{
    publicIpName = "YourPublicIpName"
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

# Deploy Key Vault
az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $keyVaultBicep --parameters $keyVaultParams --debug

# Deploy Application Insights
az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $appInsightsBicep --parameters $appInsightsParams

# Deploy Public IP
az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $publicIpBicep --parameters $publicIpParams

# Deploy Virtual Network
az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $vnetBicep --parameters $vnetParams

# Deploy Storage Account
az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $storageAccountBicep --parameters $storageAccountParams

# Deploy Virtual Machine
az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $virtualMachineBicep --parameters $vmParams
