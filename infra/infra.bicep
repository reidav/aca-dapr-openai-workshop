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
// INFRASTRUCTURE
// ------------------

module containerAppsEnvironment 'modules/infra/container-apps-env.bicep' = {
  name: '${deployment().name}-infra-container-app-env'
  params: {
    location: location
    appInsightsName: '${naming.resourceTypeAbbreviations.applicationInsights}-${resourceSuffix}'
    containerAppsEnvironmentName: '${naming.resourceTypeAbbreviations.containerAppsEnvironment}-${resourceSuffix}'
    logAnalyticsWorkspaceName: '${naming.resourceTypeAbbreviations.logAnalyticsWorkspace}-${resourceSuffix}'
    vnetName: '${naming.resourceTypeAbbreviations.virtualNetwork}-${resourceSuffix}'
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
    cosmosDbName: 'summarizer'
  }
}

module serviceBus 'modules/infra/service-bus.bicep' = {
  name: '${deployment().name}-infra-service-bus'
  params: {
    serviceBusName: '${naming.resourceTypeAbbreviations.serviceBus}-${resourceSuffix}'
    location: location
  }
}

module openai 'modules/infra/openai.bicep' = {
  name: '${deployment().name}-infra-azure-ai-studio'
  params: {
    name: '${naming.resourceTypeAbbreviations.openai}-${resourceSuffix}'
    location: location
    deployments: [
      {
        name: 'gpt-4-32k'
        model: {
          name: 'gpt-4-32k'
          version: '0613'
        }
        sku: {
          capacity: 80
        }
      }
    ]
  }
}

module keyVault 'modules/infra/keyvault.bicep' = {
  name: '${deployment().name}-infra-keyvault'
  params: {
    location: location
    keyVaultName: '${naming.resourceTypeAbbreviations.keyVault}-${resourceSuffix}'
    keyVaultUserAssignedIdentityName: '${naming.resourceTypeAbbreviations.managedIdentity}-${naming.resourceTypeAbbreviations.keyVault}-${resourceSuffix}'
    openAiApiEndpoint: openai.outputs.endpoint
    openAiApiKey: openai.outputs.key
  }
}

module webmail 'modules/infra/webmail.bicep' = {
  name: '${deployment().name}-webmail'
  params: {
    location: location
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
    containerAppName: 'webmail'
    containerAppImage: 'mailhog/mailhog'
  }
}

// ------------------
// DAPR COMPONENTS
// ------------------

module daprSmtp 'modules/dapr/smtp.bicep' = {
  name: '${deployment().name}-dapr-smtp'
  params: {
    daprComponentName: 'summarizer-smtp'
    containerAppsEnvironmentName: containerAppsEnvironment.outputs.name
    smtpHost: webmail.outputs.fqdn
    smtpPort: webmail.outputs.smtpPort
  }
}

module daprPubSub 'modules/dapr/pubsub.bicep' = {
  name: '${deployment().name}-dapr-pubsub'
  params: {
    daprComponentName: 'summarizer-pubsub'
    containerAppsEnvironmentName: containerAppsEnvironment.outputs.name
    serviceBusConnectionString: serviceBus.outputs.connectionString
  }
}

module daprStateStore 'modules/dapr/statestore.bicep' = {
  name: '${deployment().name}-dapr-statestore'
  params: {
    daprComponentName: 'summarizer-statestore'
    containerAppsEnvironmentName: containerAppsEnvironment.outputs.name
    cosmosDbName: cosmos.outputs.cosmosDbName
    cosmosCollectionName: cosmos.outputs.cosmosCollectionName
    cosmosUrl: cosmos.outputs.cosmosUrl
    cosmosKey: cosmos.outputs.cosmosKey
  }
}

module daprSecretStore 'modules/dapr/secretstore.bicep' = {
  name: '${deployment().name}-dapr-secretstore'
  params: {
    daprComponentName: 'summarizer-secretstore'
    containerAppsEnvironmentName: containerAppsEnvironment.outputs.name
    vaultName: keyVault.outputs.vaultName
    managedIdentityClientId: keyVault.outputs.vaultManagedIdentityClientId
  }
}
