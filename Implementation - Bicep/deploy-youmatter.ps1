# Set the subscription ID and project name
$subscriptionId = "86efc65b-4bd2-4a22-800e-5bff2c0a2349"
$projectName = "YouMatterTest"
$resourceGroupName = "${projectName}RG"
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
    keyVaultName = "${projectName}KV"
    location = $location
    objectId = ""
}

# Parameters for Application Insights
$appInsightsParams = @{
    appInsightsName = "${projectName}AI"
    location = $location
}

# Parameters for Virtual Machine
$vmParams = @{
    vmName = "${projectName}VM"
    location = $location
    vmSize = "Standard_DS2_v2"
    adminUsername = "YourAdminUsername"
    adminPassword = (ConvertTo-SecureString -String "YourAdminPassword" -AsPlainText -Force)
    subnetId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/virtualNetworks/${projectName}Vnet/subnets/YourSubnetName"
    networkInterfaceName = "${projectName}NIC"
    publicIpName = "${projectName}PIP"
    diskName = "${projectName}Disk"
}

# Parameters for Public IP
$publicIpParams = @{
    publicIpName = "${projectName}PIP"
    location = $location
}

# Parameters for Virtual Network
$vnetParams = @{
    vnetName = "${projectName}Vnet"
    location = $location
    addressPrefixes = @("10.0.0.0/16")
    subnetName = "YourSubnetName"
    subnetPrefix = "10.0.1.0/24"
}

# Parameters for Storage Account
$storageAccountParams = @{
    storageAccountName = "${projectName}Storage"
    location = $location
}

# Function to deploy resources
function Deploy-Resource {
    param (
        [string]$templateFile,
        [hashtable]$parameters,
        [string]$resourceDescription
    )
    try {
        az deployment group create --subscription $subscriptionId --resource-group $resourceGroupName --template-file $templateFile --parameters $parameters --debug
        Write-Host "$resourceDescription deployed successfully."
    } catch {
        Write-Error "Failed to deploy $resourceDescription. $_"
        exit 1
    }
}

# Verify Subscription and Resource Group
try {
    az account set --subscription $subscriptionId
    $resourceGroup = az group show --name $resourceGroupName --query "name" --output tsv
    if (-not $resourceGroup) {
        az group create --name $resourceGroupName --location $location --subscription $subscriptionId
        Write-Host "Resource group '$resourceGroupName' created successfully."
        Start-Sleep -Seconds 30 # Add delay to ensure the resource group creation propagates
    } else {
        Write-Host "Resource group '$resourceGroupName' already exists."
    }
} catch {
    Write-Error "Failed to verify subscription or resource group. $_"
    exit 1
}

# Create or Use Existing App Registration and Service Principal
try {
    # Retrieve the App ID of the existing Service Principal, if it exists
    $spAppId = (az ad sp list --display-name "$projectName-SP" --query "[].appId" --output tsv --all)
    
    if (-not $spAppId) {
        Write-Host "No existing Service Principal found. Creating a new one..."
        
        # Create a new Service Principal if it doesn't exist
        $sp = az ad sp create-for-rbac --name "$projectName-SP" --role Contributor --scopes "/subscriptions/$subscriptionId" --query "{appId: appId, displayName: displayName, password: password, tenant: tenant}" --output json | ConvertFrom-Json
        
        # Assign the App ID of the newly created Service Principal
        $spAppId = $sp.appId
        
        Write-Host "Service Principal '$($sp.displayName)' created successfully."
        Write-Host "App ID: $($sp.appId)"
        Write-Host "Password: $($sp.password)"
        Write-Host "Tenant: $($sp.tenant)"
    } else {
        Write-Host "Service Principal already exists. Using the existing one with App ID: $spAppId"
    }

    if ($spAppId) {
        # Retrieve the Object ID of the Service Principal
        $spObjectId = (az ad sp show --id $spAppId --query id --output tsv)
        
        if ($spObjectId) {
            Write-Host "Object ID of the Service Principal: $spObjectId"
            $keyVaultParams["objectId"] = $spObjectId

            # Assign API permissions
            Write-Host "Assigning API permissions..."
            $graphApiResourceId = "00000003-0000-0000-c000-000000000000"
            $directoryReadAllPermissionId = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
            az ad app permission add --id $spAppId --api $graphApiResourceId --api-permissions "$directoryReadAllPermissionId=Scope"
            az ad app permission grant --id $spAppId --api $graphApiResourceId --scope "/subscriptions/$subscriptionId"
            Write-Host "API permissions assigned successfully."
        } else {
            Write-Error "Failed to retrieve the Object ID of the Service Principal."
            exit 1
        }
    } else {
        Write-Error "Failed to retrieve the App ID of the Service Principal."
        exit 1
    }
} catch {
    Write-Error "Failed to create or retrieve service principal. $_"
    exit 1
}

# Assign Contributor Role to Service Principal at the Resource Group Level
try {
    $roleAssignment = az role assignment create --assignee $spObjectId --role Contributor --scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName" --query "id" --output tsv
    if ($roleAssignment) {
        Write-Host "Contributor role assigned to Service Principal at resource group level."
    } else {
        Write-Error "Failed to assign Contributor role to Service Principal."
        exit 1
    }
} catch {
    Write-Error "Failed to assign Contributor role to Service Principal. $_"
    exit 1
}

# Deploy Key Vault
Deploy-Resource -templateFile $keyVaultBicep -parameters $keyVaultParams -resourceDescription "Key Vault"

# Deploy Application Insights
Deploy-Resource -templateFile $appInsightsBicep -parameters $appInsightsParams -resourceDescription "Application Insights"

# Deploy Virtual Network
Deploy-Resource -templateFile $vnetBicep -parameters $vnetParams -resourceDescription "Virtual Network"

# Deploy Public IP
Deploy-Resource -templateFile $publicIpBicep -parameters $publicIpParams -resourceDescription "Public IP"

# Deploy Storage Account
Deploy-Resource -templateFile $storageAccountBicep -parameters $storageAccountParams -resourceDescription "Storage Account"

# Deploy Virtual Machine
Deploy-Resource -templateFile $virtualMachineBicep -parameters $vmParams -resourceDescription "Virtual Machine"
