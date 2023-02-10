// --------------------------------------------------------------------------------
// Bicep file that builds all the resource names used by other Bicep templates
// --------------------------------------------------------------------------------
param orgName string = ''
param appName string = ''
@allowed(['azd','gha','azdo','dev','demo','qa','stg','ct','prod'])
param environment string = 'azd'
param functionName string = 'processor'
param functionStorageNameSuffix string = 'store'
param dataStorageNameSuffix string = 'data'

// --------------------------------------------------------------------------------
var lowerOrgName                         = replace(toLower(orgName), ' ', '')
var sanitizedOrgName                     = replace(replace(lowerOrgName, '-', ''), '_', '')
var lowerAppName                         = replace(toLower(appName), ' ', '')
var sanitizedAppName                     = replace(replace(lowerAppName, '-', ''), '_', '')
var sanitizedEnvironment                 = toLower(environment)

// --------------------------------------------------------------------------------
var functionAppName                      = toLower('${lowerOrgName}-${lowerAppName}-${functionName}-${sanitizedEnvironment}')
var computerVisionName                   = toLower('${lowerOrgName}-${lowerAppName}-computer-vision-${sanitizedEnvironment}')
var computerVisionNetworkName            = toLower('${lowerOrgName}-${lowerAppName}-cv-vnet-${sanitizedEnvironment}')
var baseStorageName                      = toLower('${sanitizedOrgName}-${sanitizedAppName}${sanitizedEnvironment}str')

// --------------------------------------------------------------------------------
output functionAppName string            = functionAppName
output functionAppServicePlanName string = toLower('${functionAppName}-appsvc')
output functionInsightsName string       = toLower('${functionAppName}-insights')

output computerVisionNetworkName string  = computerVisionNetworkName
output computerVisionName string         = computerVisionName

// Key Vaults and Storage Accounts can only be 24 characters long
output keyVaultName string               = take(toLower('${lowerOrgName}${lowerAppName}vault${sanitizedEnvironment}'), 24)
output functionStorageName string        = take(toLower('${baseStorageName}${functionStorageNameSuffix}${uniqueString(resourceGroup().id)}'), 24)
output dataStorageName string            = take(toLower('${baseStorageName}${dataStorageNameSuffix}${uniqueString(resourceGroup().id)}'), 24)
