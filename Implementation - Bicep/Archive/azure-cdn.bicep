param cdnProfileName string
param cdnEndpointName string
param originHostName string

resource cdnProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: cdnProfileName
  location: 'Global'
  sku: {
    name: 'Standard_Microsoft'
  }
}

resource cdnEndpoint 'Microsoft.Cdn/profiles/endpoints@2021-06-01' = {
  name: cdnEndpointName
  parent: cdnProfile
  properties: {
    origins: [
      {
        name: 'YouMatterWebApp'
        properties: {
          hostName: originHostName
        }
      }
    ]
    isHttpAllowed: true
    isHttpsAllowed: true
  }
}
