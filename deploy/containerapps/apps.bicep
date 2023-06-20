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

param location string = resourceGroup().location

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

// Add each containers apps here 
