// ------------------
//    PARAMETERS
// ------------------

@description('The name of the Service Bus namespace.')
param serviceBusName string

@description('The location of the Service Bus namespace.')
param location string

// ------------------
//    RESOURCES
// ------------------

resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: serviceBusName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

output connectionString string = 'Endpoint=sb://${serviceBus.name}.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=${listKeys('${serviceBus.id}/AuthorizationRules/RootManageSharedAccessKey', serviceBus.apiVersion).primaryKey}'
