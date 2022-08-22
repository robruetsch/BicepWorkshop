// Parameters section. Write parameters directly below this line.
param location string
param servicePlanPrefix string
param webAppNamePrefix string

// Variables section. Write variables directly below this line.
var uniqstr = uniqueString(resourceGroup().id)

// Resources section
resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: '${servicePlanPrefix}${uniqstr}'
  location: location
  sku: {
    name: 'S1'
    capacity: 1
  }
}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: '${webAppNamePrefix}${uniqstr}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}
