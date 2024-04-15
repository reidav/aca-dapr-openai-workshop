targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('Container apps environment id where the container app will be deployed')
param containerAppsEnvironmentId string

@description('Assigned Identity Id for Container Registry, as container apps needs to access images')
param containerRegistryUserAssignedIdentityId string

@description('Assigned Identity Id for KeyVault, as container apps needs to access secret store')
param keyVaultUserAssignedIdentityId string

@description('Container Registry Login Server')
param containerRegistryLoginServer string

@description('Container App Name being used for deployment')
param containerAppName string

@description('Container app image being used for deployment')
param containerAppImage string

@description('Container app port being used')
param containerAppPort int

@description('PubSub Dapr Component Name being used')
param pubSubRequestsName string

@description('PubSub Dapr Component Topic being used')
param pubSubRequestsTopic string

@description('Requests API App Id being used')
param requestsApiAppId string

@description('Requests API Endpoint being used')
param requestsApiEndpoint string

param location string = resourceGroup().location

// ------------------
//    RESOURCES
// ------------------

resource containerApp 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: containerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${containerRegistryUserAssignedIdentityId}': {}
      '${keyVaultUserAssignedIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    template: {
      containers: [
        {
          name: containerAppName
          image: containerAppImage
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Development'
            }
            {
              name: 'ASPNETCORE_URLS'
              value: 'http://0.0.0.0:${containerAppPort}'
            }
            {
              name: 'PUBSUB_REQUESTS_NAME'
              value: pubSubRequestsName
            }
            {
              name: 'PUBSUB_REQUESTS_TOPIC'
              value: pubSubRequestsTopic
            }
            {
              name: 'REQUESTS_API_APP_ID'
              value: requestsApiAppId
            }
            {
              name: 'REQUESTS_API_ENDPOINT'
              value: requestsApiEndpoint
            }
          ]
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
    configuration: {
      registries: [ 
        { 
          server: containerRegistryLoginServer
          identity: containerRegistryUserAssignedIdentityId
        } 
      ]
      dapr: {
        enabled: true
        appId: containerAppName
        appPort: containerAppPort
        enableApiLogging: true
      }
      activeRevisionsMode: 'single'
      ingress: {
        external: true
        targetPort: containerAppPort
      }
    }
  }
}
