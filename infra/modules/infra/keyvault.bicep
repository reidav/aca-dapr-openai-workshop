// ------------------
//    PARAMETERS
// ------------------

@description('The name of the key vault to create.')
param keyVaultName string

@description('The name of the key vault user assigned identity to create.')
param keyVaultUserAssignedIdentityName string

@description('The location of the key vault to create.')
param location string

@description('Open AI API key')
@secure()
param openAiApiKey string

@description('Open AI Endpoint')
@secure()
param openAiApiEndpoint string

// var keyVaultAdminRoleGuid = '00482a5a-887f-4fb3-b363-3b7fe8e74483'

// ------------------
//    RESOURCES
// ------------------

resource keyVaultUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: keyVaultUserAssignedIdentityName
  location: location
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        objectId: keyVaultUserAssignedIdentity.properties.principalId
        tenantId: keyVaultUserAssignedIdentity.properties.tenantId
        permissions: {
          keys:  [
            'get'
            'list'
          ]
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    tenantId: subscription().tenantId
    enabledForTemplateDeployment: true
    enableSoftDelete: false
    softDeleteRetentionInDays: 7
    enablePurgeProtection: null  // It seems that you cannot set it to False even the first time. workaround is not to set it at all: https://github.com/Azure/bicep/issues/5223
  }
}

// ENABLE RBAC SUPPORT
// resource kevVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   name: guid(subscription().id, keyVaultName, keyVaultUserAssignedIdentityName) // This is a workaround for a bug in Bicep:
//   scope: keyVault
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultAdminRoleGuid)
//     principalId: keyVaultUserAssignedIdentity.properties.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

resource openAiApiKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'OPENAI-API-KEY'
  parent: keyVault
  properties: {
    value: openAiApiKey
  }
}

resource openAiApiEndpointSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'OPENAI-API-ENDPOINT'
  parent: keyVault
  properties: {
    value: openAiApiEndpoint
  }
}

output vaultName string = keyVault.name
output vaultManagedIdentityId string = keyVaultUserAssignedIdentity.id
output vaultManagedIdentityClientId string = keyVaultUserAssignedIdentity.properties.clientId
output vaultManagedIdentityObjectId string = keyVaultUserAssignedIdentity.properties.principalId

