param logAnalyticsWorkspaceName string
param sentinelName string
param keyVaultName string
param firewallName string
param firewallPublicIpName string
param firewallVNetName string
param firewallSubnetName string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource sentinel 'Microsoft.SecurityInsights/workspaces@2021-01-01-preview' = {
  name: sentinelName
  location: resourceGroup().location
  properties: {
    workspaceName: logAnalyticsWorkspaceName
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: resourceGroup().location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: 'YOUR_OBJECT_ID'  // Replace with your Service Principal or User object ID
        permissions: {
          keys: ['get', 'list']
          secrets: ['get', 'list']
          certificates: ['get', 'list']
        }
      }
    ]
  }
}

resource firewallVNet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: firewallVNetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.1.0.0/16']
    }
    subnets: [
      {
        name: firewallSubnetName
        properties: {
          addressPrefix: '10.1.0.0/24'
        }
      }
    ]
  }
}

resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: firewallPublicIpName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2021-03-01' = {
  name: firewallName
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'FW-config'
        properties: {
          publicIPAddress: firewallPublicIp.id
          subnet: firewallVNet.properties.subnets[0].id
        }
      }
    ]
  }
}
