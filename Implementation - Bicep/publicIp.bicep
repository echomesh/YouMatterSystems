param name string
param location string = resourceGroup().location
param sku string = 'Standard'
param allocationMethod string = 'Static'

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    publicIPAllocationMethod: allocationMethod
  }
}

output publicIpId string = publicIp.id
output publicIpAddress string = publicIp.properties.ipAddress
