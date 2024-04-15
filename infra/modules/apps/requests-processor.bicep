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

@description('Secret Dapr Component name being used')
// We disable lint of this line as it is not a secret but the name of the Dapr component
#disable-next-line secure-secrets-in-params
param secretStoreName string

@description('Requests API App Id being used')
param requestsApiAppId string

@description('Requests API Search Endpoint being used')
param requestsApiSearchEndpoint string

@description('Requests API Create Endpoint being used')
param requestsApiCreateEndpoint string

@description('OpenAI API Version being used')
param openAiApiVersion string

@description('OpenAI API Deployment Name being used')
param openAiApiDeploymentName string

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
              name: 'APP_PORT'
              value: string(containerAppPort)
            }
            {
              name: 'SECRET_STORE_NAME'
              value: secretStoreName
            }
            {
              name: 'REQUESTS_API_APP_ID'
              value: requestsApiAppId
            }
            {
              name: 'REQUESTS_API_SEARCH_ENDPOINT'
              value: requestsApiSearchEndpoint
            }
            {
              name: 'REQUESTS_API_CREATE_ENDPOINT'
              value: requestsApiCreateEndpoint
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
              name: 'OPENAI_API_VERSION'
              value: openAiApiVersion
            }
            {
              name: 'OPENAI_API_DEPLOYMENT_NAME'
              value: openAiApiDeploymentName
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
