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
var functionAppName                      = toLower('${sanitizedOrgName}-${sanitizedAppName}-${functionName}-${sanitizedEnvironment}')
var computerVisionName                   = toLower('${sanitizedOrgName}-${sanitizedAppName}-computer-vision-${sanitizedEnvironment}')
var computerVisionNetworkName            = toLower('${sanitizedOrgName}-${sanitizedAppName}-cv-vnet-${sanitizedEnvironment}')
var formsRecognizerName                  = toLower('${sanitizedOrgName}-${sanitizedAppName}-forms-recognizer-${sanitizedEnvironment}')
var baseStorageName                      = toLower('${sanitizedOrgName}${sanitizedAppName}${sanitizedEnvironment}str')

// --------------------------------------------------------------------------------
output functionAppName string            = functionAppName
output functionAppServicePlanName string = toLower('${functionAppName}-appsvc')
output functionInsightsName string       = toLower('${functionAppName}-insights')

output computerVisionNetworkName string  = computerVisionNetworkName
output computerVisionName string         = computerVisionName
output formsRecognizerName string        = formsRecognizerName

// Key Vaults and Storage Accounts can only be 24 characters long
output keyVaultName string               = take(toLower('${sanitizedOrgName}${sanitizedAppName}${sanitizedEnvironment}vault'), 24)
output functionStorageName string        = take(toLower('${baseStorageName}${functionStorageNameSuffix}'), 24)
output dataStorageName string            = take(toLower('${baseStorageName}${dataStorageNameSuffix}'), 24)
