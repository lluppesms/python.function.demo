// --------------------------------------------------------------------------------
// Bicep file that builds all the resource names used by other Bicep templates
// --------------------------------------------------------------------------------
param appName string = ''
@allowed(['azd','gha','azdo','dev','demo','qa','stg','ct','prod'])
param environment string = 'azd'
param functionName string = 'function'
param functionStorageNameSuffix string = 'store'
param dataStorageNameSuffix string = 'data'

// --------------------------------------------------------------------------------
var lowerAppName = replace(toLower(appName), ' ', '')
var sanitizedAppName = replace(replace(lowerAppName, '-', ''), '_', '')
var sanitizedEnvironment = toLower(environment)

// --------------------------------------------------------------------------------
// other resource names can be changed if desired, but if using the "azd deploy" command it expects the
// function name to be exactly "{appName}function" so don't change the functionAppName format if using azd
var functionAppName           = environment == 'azd' ? '${lowerAppName}function'                  : toLower('${lowerAppName}-${functionName}-${sanitizedEnvironment}')
var computerVisionName        = environment == 'azd' ? toLower('${lowerAppName}-computer-vision') : toLower('${lowerAppName}-computer-vision-${sanitizedEnvironment}')
var computerVisionNetworkName = environment == 'azd' ? toLower('${lowerAppName}-cv-vnet')         : toLower('${lowerAppName}-cv-vnet-${sanitizedEnvironment}')
var baseStorageName           = toLower('${sanitizedAppName}${sanitizedEnvironment}str')

// --------------------------------------------------------------------------------
output functionAppName string            = functionAppName
output functionAppServicePlanName string = toLower('${functionAppName}-appsvc')
output functionInsightsName string       = toLower('${functionAppName}-insights')

output computerVisionNetworkName string  = computerVisionNetworkName
output computerVisionName string         = computerVisionName

// Key Vaults and Storage Accounts can only be 24 characters long
output keyVaultName string               = take(toLower('${lowerAppName}vault${sanitizedEnvironment}'), 24)
output functionStorageName string        = take(toLower('${baseStorageName}${functionStorageNameSuffix}${uniqueString(resourceGroup().id)}'), 24)
output dataStorageName string            = take(toLower('${baseStorageName}${dataStorageNameSuffix}${uniqueString(resourceGroup().id)}'), 24)
