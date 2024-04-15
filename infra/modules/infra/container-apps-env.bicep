// ------------------
//    PARAMETERS
// ------------------

@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The name of the Log Analytics workspace.')
param logAnalyticsWorkspaceName string

@description('The name of the Application Insights instance.')
param appInsightsName string

@description('The name of the virtual network')
param vnetName string

@description('The location of the container apps environment.')
param location string

// ------------------
//    RESOURCES
// ------------------

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/22'
      ]
    }
    subnets: [
      {
        name: 'snet-infra'
        properties: {
          addressPrefix: '10.1.0.0/23'
          delegations: [
            {
              name: 'envdelegation'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
        }
      }]
  }
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: containerAppsEnvironmentName
  location: location
  properties: {
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    vnetConfiguration: {
      internal: false
      infrastructureSubnetId: vnet.properties.subnets[0].id
    }
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
      }
    ]
    zoneRedundant: false
  }
}

output id string = containerAppsEnvironment.id
output name string = containerAppsEnvironmentName
output domain string = containerAppsEnvironment.properties.defaultDomain
