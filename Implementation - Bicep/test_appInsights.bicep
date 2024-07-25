@mock
module appInsightsTests 'appInsights.bicep' = {
  name: 'appInsightsTests'
  params: {
    appInsightsName: 'testAppInsights'
    location: 'eastus'
  }
}

output appInsightsInstrumentationKey string = appInsightsTests.appInsightsInstrumentationKey
