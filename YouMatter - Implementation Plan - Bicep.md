### Complete Implementation Plan for YouMatter

#### Prerequisites
- Azure subscription
- Azure CLI installed
- Azure PowerShell module installed
- Access to Azure AD with sufficient permissions
- GitHub repository for the frontend code

### Step-by-Step Plan

#### 1. Azure AD Authentication

##### 1.1 Configure Azure AD

Information Needed:
- Tenant Display Name
- Domain Name
- Application Display Name
- Application Identifier URI
- Application Password
- Reply URLs
- Subscription ID

Bicep Script:
```bicep
// 1. Create Azure AD Application
resource app 'Microsoft.Graph/applications@1.0' = {
  displayName: 'YouMatter PAS App'
  signInAudience: 'AzureADMyOrg'
  web: {
    redirectUris: [
      'https://yourapp.com/auth/callback'
    ]
  }
  api: {
    identifierUris: [
      'https://youmatter.onmicrosoft.com/pas'
    ]
  }
  passwordCredentials: [
    {
      displayName: 'AppPassword'
      endDateTime: '2024-01-01T00:00:00Z'
      startDateTime: utcNow()
      secretText: 'YourStrongPassword123'
    }
  ]
}

// 2. Create Service Principal and Assign Role
resource sp 'Microsoft.Graph/servicePrincipals@1.0' = {
  appId: app.appId
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, sp.id, 'Contributor')
  properties: {
    roleDefinitionId: subscription().id + '/providers/Microsoft.Authorization/roleDefinitions/' + 'b24988ac-6180-42a0-ab88-20f7382dd24c'  // Contributor Role
    principalId: sp.id
    principalType: 'ServicePrincipal'
  }
}
```

Explanation:
- This Bicep script creates an Azure AD application, service principal, and assigns the Contributor role to the service principal.

##### 1.2 Set Up Integrations

Information Needed:
- Application ID

Scripts:
```sh
# Integrate with Azure Health Data Services
az ad app permission add --id $appId --api "00000003-0000-0000-c000-000000000000" --api-permissions "user_impersonation=Scope"

# Integrate with Office 365
az ad app permission add --id $appId --api "00000003-0000-0000-c000-000000000000" --api-permissions "Calendars.ReadWrite=Scope"

# Integrate with Azure Data Lake
az ad app permission add --id $appId --api "00000003-0000-0000-c000-000000000000" --api-permissions "user_impersonation=Scope"
```

Explanation:
- These commands add API permissions to the Azure AD application for integrating with various Azure services.

##### 1.3 Implement Conditional Access Policies

Information Needed:
- Azure AD Admin Credentials

PowerShell Script:
```powershell
# Import the AzureAD module
Import-Module AzureAD

# Connect to Azure AD
Connect-AzureAD

# Create a conditional access policy
$policy = New-AzureADMSConditionalAccessPolicy -DisplayName "Require MFA for all users" -State "Enabled" -Conditions @{
    UserRiskLevels = @("Low")
    SignInRiskLevels = @("Low", "Medium", "High")
    ClientAppTypes = @("All")
} -GrantControls @{
    Operator = "OR"
    BuiltInControls = @("Mfa")
}

# Apply the policy
Set-AzureADMSConditionalAccessPolicy -Id $policy.Id -GrantControls @{
    Operator = "OR"
    BuiltInControls = @("Mfa")
}
```

Explanation:
- This PowerShell script connects to Azure AD, creates a new conditional access policy that requires multi-factor authentication (MFA) for all users, and applies the policy.

#### 2. Azure SQL Database Managed Instance

Information Needed:
- Resource Group Name
- Managed Instance Name
- Admin Username and Password

Bicep Script:
```bicep
// 3. Create Resource Group for SQL Managed Instance
resource sqlResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'SQLResourceGroup'
  location: 'East US'
}

// 4. Create Virtual Network and Subnet
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'SQLVNet'
  location: sqlResourceGroup.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'ManagedInstanceSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// 5. Create SQL Managed Instance
resource sqlManagedInstance 'Microsoft.Sql/managedInstances@2021-02-01-preview' = {
  name: 'YouMatterManagedInstance'
  location: sqlResourceGroup.location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: 'YourStrongPassword123'
    subnetId: vnet.properties.subnets[0].id
  }
}
```

Explanation:
- These Bicep scripts create a resource group, a virtual network and subnet, and a managed instance.

#### 3. React Frontend Deployment to Azure App Service

Information Needed:
- Resource Group Name
- App Service Plan Name
- Web App Name
- GitHub Repository URL
- Branch Name

Bicep Script:
```bicep
// 6. Create Resource Group for Web App
resource webAppResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'WebAppResourceGroup'
  location: 'East US'
}

// 7. Create App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'YouMatterAppServicePlan'
  location: webAppResourceGroup.location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true  // For Linux
  }
}

// 8. Create Web App
resource webApp 'Microsoft.Web/sites@2021-01-15' = {
  name: 'YouMatterWebApp'
  location: webAppResourceGroup.location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|14-lts'
    }
  }
}

// 9. Configure Deployment from GitHub
resource webAppDeploymentSource 'Microsoft.Web/sites/SourceControls@2021-01-15' = {
  name: 'web'
  parent: webApp
  properties: {
    repoUrl: 'https://github.com/your-repo/youmatter-frontend'
    branch: 'main'
    isManualIntegration: true
  }
}
```

Explanation:
- These Bicep scripts create a resource group, an App Service Plan, a Web App, and configure deployment from a GitHub repository.

#### 4. Docker Containers and AKS

Information Needed:
- Resource Group Name
- Container Registry Name
- AKS Cluster Name
- Service Principal Client ID and Secret

Bicep Script:
```bicep
// 10. Create Resource Group for AKS
resource aksResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'AKSResourceGroup'
  location: 'East US'
}

// 11. Create Azure Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: 'YouMatterRegistry'
  location: aksResourceGroup.location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

// 12. Create AKS Cluster
resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: 'YouMatterAKSCluster'
  location: aksResourceGroup.location
  properties: {
    dnsPrefix: 'YouMatterAKS'
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: 3
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
    servicePrincipalProfile: {
      clientId: app.appId
      secret: 'YourStrongPassword123'
    }
    addonProfiles: {
      kubeDashboard: {
        enabled: true
      }
    }
    enableRBAC: true
  }
}

// 13. Attach ACR to AKS
resource roleAssignmentAcr 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(containerRegistry.id, aksCluster.properties.servicePrincipalProfile.clientId, 'AcrPull')
  properties: {
    roleDefinitionId: subscription().id + '/providers/Microsoft.Authorization/roleDefinitions/' + '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull Role
    principalId: aksCluster.properties.servicePrincipalProfile.clientId
    principalType: 'ServicePrincipal'
    scope: containerRegistry.id
  }
}
```

Explanation:
- These Bicep scripts create a resource group, an Azure Container Registry, an AKS cluster, and attach the ACR to the AKS

### Complete Implementation Plan for YouMatter

#### Prerequisites
- Azure subscription
- Azure CLI installed
- Azure PowerShell module installed
- Access to Azure AD with sufficient permissions
- GitHub repository for the frontend code

### Step-by-Step Plan

#### 1. Azure AD Authentication

##### 1.1 Configure Azure AD

Information Needed:
- Tenant Display Name
- Domain Name
- Application Display Name
- Application Identifier URI
- Application Password
- Reply URLs
- Subscription ID

Bicep Script:
```bicep
// 1. Create Azure AD Application
resource app 'Microsoft.Graph/applications@1.0' = {
  displayName: 'YouMatter PAS App'
  signInAudience: 'AzureADMyOrg'
  web: {
    redirectUris: [
      'https://yourapp.com/auth/callback'
    ]
  }
  api: {
    identifierUris: [
      'https://youmatter.onmicrosoft.com/pas'
    ]
  }
  passwordCredentials: [
    {
      displayName: 'AppPassword'
      endDateTime: '2024-01-01T00:00:00Z'
      startDateTime: utcNow()
      secretText: 'YourStrongPassword123'
    }
  ]
}

// 2. Create Service Principal and Assign Role
resource sp 'Microsoft.Graph/servicePrincipals@1.0' = {
  appId: app.appId
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, sp.id, 'Contributor')
  properties: {
    roleDefinitionId: subscription().id + '/providers/Microsoft.Authorization/roleDefinitions/' + 'b24988ac-6180-42a0-ab88-20f7382dd24c'  // Contributor Role
    principalId: sp.id
    principalType: 'ServicePrincipal'
  }
}
```

Explanation:
- This Bicep script creates an Azure AD application, service principal, and assigns the Contributor role to the service principal.

##### 1.2 Set Up Integrations

Information Needed:
- Application ID

Scripts:
```sh
# Integrate with Azure Health Data Services
az ad app permission add --id $appId --api "00000003-0000-0000-c000-000000000000" --api-permissions "user_impersonation=Scope"

# Integrate with Office 365
az ad app permission add --id $appId --api "00000003-0000-0000-c000-000000000000" --api-permissions "Calendars.ReadWrite=Scope"

# Integrate with Azure Data Lake
az ad app permission add --id $appId --api "00000003-0000-0000-c000-000000000000" --api-permissions "user_impersonation=Scope"
```

Explanation:
- These commands add API permissions to the Azure AD application for integrating with various Azure services.

##### 1.3 Implement Conditional Access Policies

Information Needed:
- Azure AD Admin Credentials

PowerShell Script:
```powershell
# Import the AzureAD module
Import-Module AzureAD

# Connect to Azure AD
Connect-AzureAD

# Create a conditional access policy
$policy = New-AzureADMSConditionalAccessPolicy -DisplayName "Require MFA for all users" -State "Enabled" -Conditions @{
    UserRiskLevels = @("Low")
    SignInRiskLevels = @("Low", "Medium", "High")
    ClientAppTypes = @("All")
} -GrantControls @{
    Operator = "OR"
    BuiltInControls = @("Mfa")
}

# Apply the policy
Set-AzureADMSConditionalAccessPolicy -Id $policy.Id -GrantControls @{
    Operator = "OR"
    BuiltInControls = @("Mfa")
}
```

Explanation:
- This PowerShell script connects to Azure AD, creates a new conditional access policy that requires multi-factor authentication (MFA) for all users, and applies the policy.

#### 2. Azure SQL Database Managed Instance

Information Needed:
- Resource Group Name
- Managed Instance Name
- Admin Username and Password

Bicep Script:
```bicep
// 3. Create Resource Group for SQL Managed Instance
resource sqlResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'SQLResourceGroup'
  location: 'East US'
}

// 4. Create Virtual Network and Subnet
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'SQLVNet'
  location: sqlResourceGroup.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'ManagedInstanceSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// 5. Create SQL Managed Instance
resource sqlManagedInstance 'Microsoft.Sql/managedInstances@2021-02-01-preview' = {
  name: 'YouMatterManagedInstance'
  location: sqlResourceGroup.location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: 'YourStrongPassword123'
    subnetId: vnet.properties.subnets[0].id
  }
}
```

Explanation:
- These Bicep scripts create a resource group, a virtual network and subnet, and a managed instance.

#### 3. React Frontend Deployment to Azure App Service

Information Needed:
- Resource Group Name
- App Service Plan Name
- Web App Name
- GitHub Repository URL
- Branch Name

Bicep Script:
```bicep
// 6. Create Resource Group for Web App
resource webAppResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'WebAppResourceGroup'
  location: 'East US'
}

// 7. Create App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'YouMatterAppServicePlan'
  location: webAppResourceGroup.location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true  // For Linux
  }
}

// 8. Create Web App
resource webApp 'Microsoft.Web/sites@2021-01-15' = {
  name: 'YouMatterWebApp'
  location: webAppResourceGroup.location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|14-lts'
    }
  }
}

// 9. Configure Deployment from GitHub
resource webAppDeploymentSource 'Microsoft.Web/sites/SourceControls@2021-01-15' = {
  name: 'web'
  parent: webApp
  properties: {
    repoUrl: 'https://github.com/your-repo/youmatter-frontend'
    branch: 'main'
    isManualIntegration: true
  }
}
```

Explanation:
- These Bicep scripts create a resource group, an App Service Plan, a Web App, and configure deployment from a GitHub repository.

#### 4. Docker Containers and AKS

Information Needed:
- Resource Group Name
- Container Registry Name
- AKS Cluster Name
- Service Principal Client ID and Secret

Bicep Script:
```bicep
// 10. Create Resource Group for AKS
resource aksResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'AKSResourceGroup'
  location: 'East US'
}

// 11. Create Azure Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: 'YouMatterRegistry'
  location: aksResourceGroup.location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

// 12. Create AKS Cluster
resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: 'YouMatterAKSCluster'
  location: aksResourceGroup.location
  properties: {
    dnsPrefix: 'YouMatterAKS'
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: 3
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
    servicePrincipalProfile: {
      clientId: app.appId
      secret: 'YourStrongPassword123'
    }
    addonProfiles: {
      kubeDashboard: {
        enabled: true
      }
    }
    enableRBAC: true
  }
}

// 13. Attach ACR to AKS
resource roleAssignmentAcr 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(containerRegistry.id, aksCluster.properties.servicePrincipalProfile.clientId, 'AcrPull')
  properties: {
    roleDefinitionId: subscription().id + '/providers/Microsoft.Authorization/roleDefinitions/' + '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull Role
    principalId: aksCluster.properties.servicePrincipalProfile.clientId
    principalType: 'ServicePrincipal'
    scope: containerRegistry.id
  }
}
```

Explanation:
- These Bicep scripts create a resource group, an Azure Container Registry, an AKS cluster, and attach the ACR to the AKS

### Find and Replace Syntax for Cleaning Up the Script

To clean up your script and format it properly with the correct code block delimiters, you can use the following find and replace syntax.

#### Find:
```
bicep // 6. Create Resource Group for Web App resource webAppResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = { name: 'WebAppResourceGroup' location: 'East US' } // 7. Create App Service Plan resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = { name: 'YouMatterAppServicePlan' location: webAppResourceGroup.location sku: { name: 'B1' tier: 'Basic' } properties: { reserved: true // For Linux } } // 8. Create Web App resource webApp 'Microsoft.Web/sites@2021-01-15' = { name: 'YouMatterWebApp' location: webAppResourceGroup.location properties: { serverFarmId: appServicePlan.id siteConfig: { linuxFxVersion: 'NODE|14-lts' } } } // 9. Configure Deployment from GitHub resource webAppDeploymentSource 'Microsoft.Web/sites/SourceControls@2021-01-15' = { name: 'web' parent: webApp properties: { repoUrl: 'https://github.com/your-repo/youmatter-frontend (https://github.com/your-repo/youmatter-frontend)' branch: 'main' isManualIntegration: true } } // 10. Create Resource Group for AKS resource aksResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = { name: 'AKSResourceGroup' location: 'East US' } // 11. Create Azure Container Registry resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = { name: 'YouMatterRegistry' location: aksResourceGroup.location sku: { name: 'Basic' } properties: { adminUserEnabled: true } } // 12. Create AKS Cluster resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = { name: 'YouMatterAKSCluster' location: aksResourceGroup.location properties: { dnsPrefix: 'YouMatterAKS' agentPoolProfiles: [ { name: 'nodepool1' count: 3 vmSize: 'Standard_DS2_v2' osType: 'Linux' type: 'VirtualMachineScaleSets' mode: 'System' } ] servicePrincipalProfile: { clientId: app.appId secret: 'YourStrongPassword123' } addonProfiles: { kubeDashboard: { enabled: true } } enableRBAC: true } } // 13. Attach ACR to AKS resource roleAssignmentAcr 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = { name: guid(containerRegistry.id, aksCluster.properties.servicePrincipalProfile.clientId, 'AcrPull') properties: { roleDefinitionId: subscription().id + '/providers/Microsoft.Authorization/roleDefinitions/' + '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull Role principalId: aksCluster.properties.servicePrincipalProfile.clientId principalType: 'ServicePrincipal' scope: containerRegistry.id } }
```

#### Replace:
```
```bicep
// 6. Create Resource Group for Web App
resource webAppResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'WebAppResourceGroup'
  location: 'East US'
}

// 7. Create App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'YouMatterAppServicePlan'
  location: webAppResourceGroup.location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true  // For Linux
  }
}

// 8. Create Web App
resource webApp 'Microsoft.Web/sites@2021-01-15' = {
  name: 'YouMatterWebApp'
  location: webAppResourceGroup.location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|14-lts'
    }
  }
}

// 9. Configure Deployment from GitHub
resource webAppDeploymentSource 'Microsoft.Web/sites/SourceControls@2021-01-15' = {
  name: 'web'
  parent: webApp
  properties: {
    repoUrl: 'https://github.com/your-repo/youmatter-frontend'
    branch: 'main'
    isManualIntegration: true
  }
}
```

Explanation:
- This replaces the script block with properly formatted code delimiters for Bicep scripts.

### Template for Documenting Scripts

Here is a structured template for documenting your scripts, including a naming reference.

---

### Script Documentation Template

#### Script Name: `1.1: Configure Azure AD`

---

**Description:**

This script configures Azure AD by creating a tenant, registering an application, creating a service principal, and assigning roles.

**Variables:**

| Variable Name            | Description                                  | Required Input |
|--------------------------|----------------------------------------------|----------------|
| tenantDisplayName        | Display Name of the Azure AD Tenant          | No             |
| domainName               | Domain Name for the Azure AD Tenant          | No             |
| applicationDisplayName   | Display Name of the Application              | No             |
| applicationIdentifierURI | Identifier URI for the Application           | No             |
| applicationPassword      | Password for the Application                 | Yes            |
| replyURLs                | Reply URLs for the Application               | Yes            |
| subscriptionID           | Azure Subscription ID                        | Yes            |

**Script:**

```sh
#!/bin/bash

# Variables
tenantDisplayName="YouMatter Tenant"
domainName="youmatter.onmicrosoft.com"
applicationDisplayName="YouMatter PAS App"
applicationIdentifierURI="https://youmatter.onmicrosoft.com/pas"
applicationPassword="YourStrongPassword123"  # * Enter your application password
replyURLs="https://yourapp.com/auth/callback"  # * Enter your reply URLs
subscriptionID="yourSubscriptionId"  # * Enter your subscription ID

# Create a new Azure AD tenant
az ad tenant create --display-name "$tenantDisplayName" --domain-name "$domainName"

# Register a new application
appCreateOutput=$(az ad app create --display-name "$applicationDisplayName" --identifier-uris "$applicationIdentifierURI" --password "$applicationPassword" --reply-urls "$replyURLs")
appId=$(echo $appCreateOutput | jq -r '.appId')

# Create a service principal for the application
spCreateOutput=$(az ad sp create --id $appId)
spId=$(echo $spCreateOutput | jq -r '.objectId')

# Assign roles to the service principal
az role assignment create --assignee $spId --role "Contributor" --scope "/subscriptions/$subscriptionID"

# Output the captured values
echo "Tenant Display Name: $tenantDisplayName"
echo "Domain Name: $domainName"
echo "Application Display Name: $applicationDisplayName"
echo "Application Identifier URI: $applicationIdentifierURI"
echo "Application Password: $applicationPassword"
echo "Reply URLs: $replyURLs"
echo "Subscription ID: $subscriptionID"
echo "Application ID: $appId"
echo "Service Principal ID: $spId"
```

**Instructions:**

1. Ensure you have the Azure CLI installed and authenticated.
2. Update the variables marked with an asterisk (*) with your specific information.
3. Run the script in your terminal to configure Azure AD.

**Notes:**

- Ensure `jq` is installed for JSON parsing.
- This script assumes you have the necessary permissions to create Azure AD tenants and applications.

---

Feel free to update this template with your specific details and use it for documenting all your scripts. If you need further assistance, just let me know!
