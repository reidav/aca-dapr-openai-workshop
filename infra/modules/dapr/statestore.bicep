targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------
@description('Name of the Container Apps environment')
param containerAppsEnvironmentName string

@description('Name of the Dapr PubSub component')
param daprComponentName string

@description('Name of the Cosmos DB database')
param cosmosDbName string

@description('Name of the Cosmos DB collection')
param cosmosCollectionName string

@description('URL of the Cosmos DB instance')
param cosmosUrl string

@secure()
param cosmosKey string

// ------------------
//    RESOURCES
// ------------------

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName

  resource daprComponent 'daprComponents@2022-03-01' = {
    name: daprComponentName
    properties: {
      componentType: 'state.azure.cosmosdb'
      version: 'v1'
      initTimeout: '5m'
      secrets: [
        {
          name: 'cosmos-key'
          value: cosmosKey
        }
      ]
      metadata: [
        {
          name: 'url'
          value: cosmosUrl
        }
        {
          name: 'masterKey'
          secretRef: 'cosmos-key'
        }
        {
          name: 'database'
          value: cosmosDbName
        }
        {
          name: 'collection'
          value: cosmosCollectionName
        }
        {
          name: 'actorStateStore'
          value: 'true'
        }
      ]
      scopes:[
        'summarizer-requests-api'
      ]
    }
  }
}

output daprStateStoreName string = containerAppsEnvironment::daprComponent.name
