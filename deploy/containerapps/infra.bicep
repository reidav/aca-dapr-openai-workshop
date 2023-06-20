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

@minLength(1)
param uniqueId string

@description('The SMTP host to use for sending emails.')
@secure()
param smtpHost string

@description('The SMTP port to use for sending emails.')
param smtpPort int

@description('Open AI API key')
@secure()
param openAiApiKey string

@description('Open AI Endpoint')
@secure()
param openAiApiEndpoint string

param location string = resourceGroup().location

// ------------------
// VARIABLES
// ------------------

var naming = json(loadTextContent('./naming-rules.json'))

var resourceSuffix = format('{0}-{1}-{2}-{3}',
  environment,
  naming.regionAbbreviations[location],
  workloadName,
  uniqueId
)

// ------------------
// INFRASTRUCTURE
// ------------------

module containerAppsEnvironment 'modules/infra/container-apps-env.bicep' = {
  name: '${deployment().name}-infra-container-app-env'
  params: {
    location: location
    appInsightsName: '${naming.resourceTypeAbbreviations.applicationInsights}-${resourceSuffix}'
    containerAppsEnvironmentName: '${naming.resourceTypeAbbreviations.containerAppsEnvironment}-${resourceSuffix}'
    logAnalyticsWorkspaceName: '${naming.resourceTypeAbbreviations.logAnalyticsWorkspace}-${resourceSuffix}'
  }
}

module containerRegistry 'modules/infra/container-registry.bicep' = {
  name: '${deployment().name}-infra-container-registry'
  params: {
    location: location
    containerRegistryName: replace('${naming.resourceTypeAbbreviations.containerRegistry}-${resourceSuffix}', '-', '')
    containerRegistryUserAssignedIdentityName: '${naming.resourceTypeAbbreviations.managedIdentity}-${naming.resourceTypeAbbreviations.containerRegistry}-${resourceSuffix}'
  }
}

module cosmos 'modules/infra/cosmos-db.bicep' = {
  name: '${deployment().name}-infra-cosmos-db'
  params: {
    location: location
    cosmosAccountName: '${naming.resourceTypeAbbreviations.cosmosDbNoSql}-${resourceSuffix}'
    cosmosDbName:  'summarizer'
  }
}

module serviceBus 'modules/infra/service-bus.bicep' = {
  name: '${deployment().name}-infra-service-bus'
  params: {
    serviceBusName: '${naming.resourceTypeAbbreviations.serviceBus}-${resourceSuffix}'
    location: location
  }
}

module keyVault 'modules/infra/keyvault.bicep' = {
  name: '${deployment().name}-infra-keyvault'
  params: {
    location: location
    keyVaultName: '${naming.resourceTypeAbbreviations.keyVault}-${resourceSuffix}'
    keyVaultUserAssignedIdentityName:'${naming.resourceTypeAbbreviations.managedIdentity}-${naming.resourceTypeAbbreviations.keyVault}-${resourceSuffix}'
    openAiApiEndpoint: openAiApiEndpoint
    openAiApiKey: openAiApiKey
  }
}

// ------------------
// DAPR COMPONENTS
// ------------------

// Add each dapr components here 
