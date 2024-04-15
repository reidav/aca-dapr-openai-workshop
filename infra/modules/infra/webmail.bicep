targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('Container apps environment id where the container app will be deployed')
param containerAppsEnvironmentId string

@description('Container App Name being used for deployment')
param containerAppName string

@description('Container app image being used for deployment')
param containerAppImage string

param location string = resourceGroup().location

// ------------------
//    RESOURCES
// ------------------

resource containerApp 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    template: {
      containers: [
        {
          name: containerAppName
          image: containerAppImage
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
      activeRevisionsMode: 'single'

      ingress: {
        additionalPortMappings: [
          {
            exposedPort: 1025
            external: true
            targetPort: 1025
          }
        ]
        external: true
        targetPort: 8025
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
output smtpPort int = 1025
