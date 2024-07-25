param aksClusterName string
param agentPoolName string
param agentCount int
param agentVMSize string
param servicePrincipalClientId string
param servicePrincipalClientSecret securestring

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: aksClusterName
  location: resourceGroup().location
  properties: {
    dnsPrefix: aksClusterName
    agentPoolProfiles: [
      {
        name: agentPoolName
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
      }
    ]
    servicePrincipalProfile: {
      clientId: servicePrincipalClientId
      secret: servicePrincipalClientSecret
    }
    addonProfiles: {
      kubeDashboard: {
        enabled: true
      }
    }
    enableRBAC: true
  }
}
