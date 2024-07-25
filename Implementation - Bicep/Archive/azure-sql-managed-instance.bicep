param managedInstanceName string
param adminUsername string
param adminPassword securestring
param subnetId string

resource sqlManagedInstance 'Microsoft.Sql/managedInstances@2021-02-01-preview' = {
  name: managedInstanceName
  location: resourceGroup().location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    subnetId: subnetId
  }
}
