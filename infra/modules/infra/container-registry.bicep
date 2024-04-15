// ------------------
//    PARAMETERS
// ------------------

@description('container registry name')
param containerRegistryName string

@description('The name of the user assigned identity to create.')
param containerRegistryUserAssignedIdentityName string

@description('The location of the container registry.')
param location string

var containerRegistryPullRoleGuid = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

// ------------------
//    RESOURCES
// ------------------

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource containerRegistryUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: containerRegistryUserAssignedIdentityName
  location: location
}

resource containerRegistryRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, containerRegistryName, containerRegistryUserAssignedIdentityName) 
  scope: containerRegistry
  properties: {
    principalId: containerRegistryUserAssignedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', containerRegistryPullRoleGuid)
    principalType: 'ServicePrincipal'
  }
}

output containerRegistryName string = containerRegistry.name
output containerRegistryManagedIdentityId string = containerRegistryUserAssignedIdentity.id
output containerRegistryManagedIdentityClientId string = containerRegistryUserAssignedIdentity.properties.clientId
output containerRegistryManagedIdentityObjectId string = containerRegistryUserAssignedIdentity.properties.principalId

