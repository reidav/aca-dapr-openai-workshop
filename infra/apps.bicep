targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@minLength(2)
@maxLength(10)
@description('The name of the workloard that is being deployed. Up to 10 characters long.')
param workloadName string

@minLength(2)
@maxLength(8)
@description('The name of the environment (e.g. "dev", "test", "prod", "uat", "dr", "qa") Up to 8 characters long.')
param environment string

@description('The tag to use for the image.')
param imageTag string

@minLength(1)
param uniqueId string

param location string = resourceGroup().location

// ------------------
// VARIABLES
// ------------------

var naming = json(loadTextContent('./naming-rules.json'))

var resourceSuffix = format(
  '{0}-{1}-{2}-{3}',
  environment,
  naming.regionAbbreviations[location],
  workloadName,
  uniqueId
)

// ------------------
// CONTAINER APPS
// ------------------

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: '${naming.resourceTypeAbbreviations.containerAppsEnvironment}-${resourceSuffix}'
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-12-01' existing = {
  name: replace('${naming.resourceTypeAbbreviations.containerRegistry}-${resourceSuffix}', '-', '')
}

resource containerRegistryUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${naming.resourceTypeAbbreviations.managedIdentity}-${naming.resourceTypeAbbreviations.containerRegistry}-${resourceSuffix}'
  location: location
}

resource keyVaultUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${naming.resourceTypeAbbreviations.managedIdentity}-${naming.resourceTypeAbbreviations.keyVault}-${resourceSuffix}'
  location: location
}

module frontend 'modules/apps/requests-frontend.bicep' = {
  name: '${deployment().name}-summarizer-frontend'
  params: {
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.id
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentity.id
    keyVaultUserAssignedIdentityId: keyVaultUserAssignedIdentity.id

    containerRegistryLoginServer: containerRegistry.properties.loginServer
    containerAppName: 'summarizer-frontend'
    containerAppImage: '${containerRegistry.properties.loginServer}/summarizer/requests-frontend:${imageTag}'
    containerAppPort: 80

    pubSubRequestsName: 'summarizer-pubsub'
    pubSubRequestsTopic: 'link-to-summarize'
    requestsApiAppId: 'summarizer-requests-api'
    requestsApiEndpoint: 'requests'
  }
}

module requests_api 'modules/apps/requests-api.bicep' = {
  name: '${deployment().name}-summarizer-requests-api'
  params: {
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.id
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentity.id
    keyVaultUserAssignedIdentityId: keyVaultUserAssignedIdentity.id

    containerRegistryLoginServer: containerRegistry.properties.loginServer
    containerAppName: 'summarizer-requests-api'
    containerAppImage: '${containerRegistry.properties.loginServer}/summarizer/requests-api:${imageTag}'
    containerAppPort: 80
    stateStoreName: 'summarizer-statestore'
    bindingSmtp: 'summarizer-smtp'
  }
}

module requests_processor 'modules/apps/requests-processor.bicep' = {
  name: '${deployment().name}-summarizer-requests-processor'
  params: {
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.id
    containerRegistryUserAssignedIdentityId: containerRegistryUserAssignedIdentity.id
    keyVaultUserAssignedIdentityId: keyVaultUserAssignedIdentity.id

    containerRegistryLoginServer: containerRegistry.properties.loginServer
    containerAppName: 'summarizer-requests-processor'
    containerAppImage: '${containerRegistry.properties.loginServer}/summarizer/requests-processor:${imageTag}'
    containerAppPort: 80
    pubSubRequestsName: 'summarizer-pubsub'
    pubSubRequestsTopic: 'link-to-summarize'
    openAiApiDeploymentName: 'gpt-4-32k'
    openAiApiVersion: '2024-02-15-preview'
    secretStoreName: 'summarizer-secretstore'
    requestsApiAppId: 'summarizer-requests-api'
    requestsApiCreateEndpoint: 'requests'
    requestsApiSearchEndpoint: 'search-requests-by-url'
  }
}
