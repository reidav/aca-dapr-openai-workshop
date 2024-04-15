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

@description('State Dapr Component name being used')
param stateStoreName string

@description('Binding Dapr Component name being used')
param bindingSmtp string

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
              name: 'STATE_STORE_NAME'
              value: stateStoreName
            }
            {
              name: 'BINDING_SMTP'
              value: bindingSmtp
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
