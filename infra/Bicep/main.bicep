// --------------------------------------------------------------------------------
// Main Bicep file that creates all of the Azure Resources for one environment
// --------------------------------------------------------------------------------
// To deploy this Bicep manually:
// 	 az login
//   az account set --subscription <subscriptionId>
//   Test Pipeline deploy:
//     az deployment group create -n main-deploy-20230210T130100Z --resource-group rg-xxx-pyocr-demo --template-file 'main.bicep' --parameters orgName=xxx appName=pyocr environmentCode=demo keyVaultOwnerUserId=xxxxxxxx-xxxx-xxxx
// --------------------------------------------------------------------------------
param orgName string = ''
param appName string = 'pyocr'
@allowed(['azd','gha','azdo','dev','demo','qa','stg','ct','prod'])
param environmentCode string = 'dev'
param location string = resourceGroup().location
param keyVaultOwnerUserId string = ''

// optional parameters
@allowed(['Standard_LRS','Standard_GRS','Standard_RAGRS'])
param storageSku string = 'Standard_LRS'
param functionName string = 'function'
param functionAppSku string = 'Y1'
param functionAppSkuFamily string = 'Y'
param functionAppSkuTier string = 'Dynamic'
param keyVaultOwnerIpAddress string = ''
param runDateTime string = utcNow()

// --------------------------------------------------------------------------------
var deploymentSuffix = '-${runDateTime}'
var commonTags = {         
  LastDeployed: runDateTime
  Application: appName
  Environment: environmentCode
}

// --------------------------------------------------------------------------------
module resourceNames 'resourcenames.bicep' = {
  name: 'resourcenames${deploymentSuffix}'
  params: {
    orgName: orgName
    appName: appName
    environment: environmentCode
    functionName: functionName
    functionStorageNameSuffix: 'store'
    dataStorageNameSuffix: 'data'
  }
}

// --------------------------------------------------------------------------------
module functionStorageModule 'storageaccount.bicep' = {
  name: 'functionstorage${deploymentSuffix}'
  params: {
    storageAccountName: resourceNames.outputs.functionStorageName
    location: location
    commonTags: commonTags
    storageSku: storageSku
    containerNames: []
  }
}
module dataStorageModule 'storageaccount.bicep' = {
  name: 'datastorage${deploymentSuffix}'
  params: {
    storageAccountName: resourceNames.outputs.dataStorageName
    location: location
    commonTags: commonTags
    storageSku: storageSku
    containerNames: [
      'inputfiles'
      'outputfiles'
    ]
  }
}
module functionModule 'functionpythonapp.bicep' = {
  name: 'functionApp${deploymentSuffix}'
  dependsOn: [ functionStorageModule ]
  params: {
    functionAppName: resourceNames.outputs.functionAppName
    functionAppServicePlanName: resourceNames.outputs.functionAppServicePlanName
    functionInsightsName: resourceNames.outputs.functionInsightsName

    appInsightsLocation: location
    location: location
    commonTags: commonTags

    // functionKind: 'functionapp,linux'
    functionAppSku: functionAppSku
    functionAppSkuFamily: functionAppSkuFamily
    functionAppSkuTier: functionAppSkuTier
    functionStorageAccountName: functionStorageModule.outputs.name
  }
}
module computerVisionModule 'computervision.bicep' = {
  name: 'computervision${deploymentSuffix}'
  params: {
    computerVisionName: resourceNames.outputs.computerVisionName
    location: location
    commonTags: commonTags
    // virtualNetworkName: resourceNames.outputs.computerVisionNetworkName
  }
}
module keyVaultModule 'keyvault.bicep' = {
  name: 'keyvault${deploymentSuffix}'
  dependsOn: [ functionModule, computerVisionModule ]
  params: {
    keyVaultName: resourceNames.outputs.keyVaultName
    location: location
    commonTags: commonTags
    adminUserObjectIds: []
    keyVaultOwnerUserId: keyVaultOwnerUserId
    applicationUserObjectIds: [ functionModule.outputs.principalId ]
    keyVaultOwnerIpAddress: keyVaultOwnerIpAddress
    enableSoftDelete: false
  }
}
module keyVaultSecret1 'keyvaultsecret.bicep' = {
  name: 'keyVaultSecret1${deploymentSuffix}'
  dependsOn: [ keyVaultModule, functionModule ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    secretName: 'functionAppInsightsKey'
    secretValue: functionModule.outputs.insightsKey
  }
}
module keyVaultSecret2 'keyvaultsecretstorageconnection.bicep' = {
  name: 'keyVaultSecret2${deploymentSuffix}'
  dependsOn: [ keyVaultModule, functionStorageModule ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    keyName: 'functionStorageAccountConnectionString'
    storageAccountName: functionStorageModule.outputs.name
  }
}
module keyVaultSecret3 'keyvaultsecretstorageconnection.bicep' = {
  name: 'keyVaultSecret3${deploymentSuffix}'
  dependsOn: [ keyVaultModule, dataStorageModule ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    keyName: 'DataStorageConnectionAppSetting'
    storageAccountName: dataStorageModule.outputs.name
  }
}
module keyVaultSecret4 'keyvaultsecretcomputervision.bicep' = {
  name: 'keyVaultSecret4${deploymentSuffix}'
  dependsOn: [ keyVaultModule, computerVisionModule ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    keyName: 'ComputerVisionAccessKey'
    computerVisionName: resourceNames.outputs.computerVisionName
  }
}
module functionAppSettingsModule 'functionpythonappsettings.bicep' = {
  name: 'functionAppSettings${deploymentSuffix}'
  dependsOn: [ keyVaultSecret1, keyVaultSecret2, keyVaultSecret3, keyVaultSecret4, functionModule ]
  params: {
    functionAppName: functionModule.outputs.name
    functionStorageAccountName: functionModule.outputs.storageAccountName
    functionInsightsKey: functionModule.outputs.insightsKey
    customAppSettings: {
      DataStorageConnectionAppSetting: '@Microsoft.KeyVault(VaultName=${keyVaultModule.outputs.name};SecretName=DataStorageConnectionAppSetting)'
      ComputerVisionAccessKey: '@Microsoft.KeyVault(VaultName=${keyVaultModule.outputs.name};SecretName=ComputerVisionAccessKey)'
      ComputerVisionResourceName: resourceNames.outputs.computerVisionName
      ComputerVisionRegion: computerVisionModule.outputs.location
    }
  }
}
