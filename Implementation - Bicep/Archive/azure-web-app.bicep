param appServicePlanName string
param webAppName string
param gitHubRepoURL string
param branchName string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: appServicePlanName
  location: resourceGroup().location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2021-01-15' = {
  name: webAppName
  location: resourceGroup().location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|14-lts'
    }
  }
}

resource webAppSourceControl 'Microsoft.Web/sites/sourcecontrols@2021-01-15' = {
  name: '${webAppName}/web'
  properties: {
    repoUrl: gitHubRepoURL
    branch: branchName
    isManualIntegration: true
  }
}
