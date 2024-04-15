param name string
param location string = resourceGroup().location
param tags object = {}

param customSubDomainName string = name
param deployments array = []
param kind string = 'OpenAI'
param publicNetworkAccess string = 'Enabled'
param sku object = {
  name: 'S0'
}

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    customSubDomainName: customSubDomainName
    publicNetworkAccess: publicNetworkAccess
  }
  sku: sku
}

@batchSize(1)
resource openaiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  name: deployment.name
  sku: {
    capacity: deployment.sku.capacity
    name: 'Standard'
  }
  parent: account
  properties: {
    model: {
      format: 'OpenAI'
      name: deployment.model.name
      version: deployment.model.version
    }
    raiPolicyName: 'Microsoft.Default'
    versionUpgradeOption: 'OnceCurrentVersionExpired'
  }
}]

output endpoint string = account.properties.endpoint
output key string = account.listKeys().key1
output id string = account.id
output name string = account.name
