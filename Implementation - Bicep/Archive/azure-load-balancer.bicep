param publicIpName string
param loadBalancerName string

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: publicIpName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2021-03-01' = {
  name: loadBalancerName
  location: resourceGroup().location
  properties: {
    frontendIPConfigurations: [
      {
        name: 'YouMatterFrontEnd'
        properties: {
          publicIPAddress: publicIp.id
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'YouMatterBackEndPool'
      }
    ]
    probes: [
      {
        name: 'YouMatterHealthProbe'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'YouMatterLoadBalancerRule'
        properties: {
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          frontendIPConfiguration: loadBalancer.properties.frontendIPConfigurations[0]
          backendAddressPool: loadBalancer.properties.backendAddressPools[0]
          probe: loadBalancer.properties.probes[0]
        }
      }
    ]
  }
}
