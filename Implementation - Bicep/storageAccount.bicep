param name string
param location string = resourceGroup().location
param sku string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {}
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
