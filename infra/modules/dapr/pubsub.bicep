targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('Name of the Dapr PubSub component')
param daprComponentName string

@description('Name of the Azure Container Apps environment')
param containerAppsEnvironmentName string

@description('Service Bus connection string')
@secure()
param serviceBusConnectionString string

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName

  resource daprComponent 'daprComponents@2022-03-01' = {
    name: daprComponentName
    properties: {
      componentType: 'pubsub.azure.servicebus'
      version: 'v1'
      secrets: [
        {
          name: 'service-bus-connection-string'
          value: serviceBusConnectionString
        }
      ]
      metadata: [
        {
          name: 'connectionString'
          secretRef: 'service-bus-connection-string'
        }
      ]
      scopes:[
        'summarizer-requests-processor'
        'summarizer-frontend'
      ]
    }
  }
}

output daprPubSubName string = containerAppsEnvironment::daprComponent.name
