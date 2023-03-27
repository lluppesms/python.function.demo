// --------------------------------------------------------------------------------
// This BICEP file will add unique Configuration settings to a web or function app
// ----------------------------------------------------------------------------------------------------
param functionAppName string = 'myfunctionname'
param customAppSettings object = {}

// param functionStorageAccountName string = 'myfunctionstoragename'
// param functionInsightsKey string = 'myKey'
// resource storageAccountResource 'Microsoft.Storage/storageAccounts@2019-06-01' existing = { name: functionStorageAccountName }
// var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountResource.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountResource.id, storageAccountResource.apiVersion).keys[0].value}'
// var BASE_SLOT_APPSETTINGS = {
//   AzureWebJobsStorage: storageAccountConnectionString
//   WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccountConnectionString
//   WEBSITE_CONTENTSHARE: functionAppName
//   // APPINSIGHTS_INSTRUMENTATIONKEY: functionInsightsKey
//   APPLICATIONINSIGHTS_CONNECTION_STRING: 'InstrumentationKey=${functionInsightsKey}'
//   FUNCTIONS_WORKER_RUNTIME: 'python'
//   FUNCTIONS_EXTENSION_VERSION: '~4'
//   WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
// }
// resource siteConfig 'Microsoft.Web/sites/config@2021-02-01' = {
//   name: '${functionAppName}/appsettings'
//   properties: union(BASE_SLOT_APPSETTINGS, customAppSettings)
// }

resource functionAppResource 'Microsoft.Web/sites@2022-03-01' existing = { name: functionAppName }
var BASE_SLOT_APPSETTINGS = list('${functionAppResource.id}/config/appsettings', functionAppResource.apiVersion).properties
var updatedSettings = union(BASE_SLOT_APPSETTINGS, customAppSettings)
resource siteConfig 'Microsoft.Web/sites/config@2021-02-01' = {
  name: 'appsettings'
  parent: functionAppResource
  properties: updatedSettings
}
