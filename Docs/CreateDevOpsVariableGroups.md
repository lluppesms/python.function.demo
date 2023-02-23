# Set up an Azure DevOps Variable Groups

## Note: The Azure DevOps pipelines needs a variable group named "PythonDemo"

To create these variable groups, customize and run this command in the Azure Cloud Shell:

``` bash
   az login

   az pipelines variable-group create 
     --organization=https://dev.azure.com/<yourAzDOOrg>/ 
     --project='<yourAzDOProject>' 
     --name PythonDemo 
     --variables 
         appName='<yourInitials>-pyocr' 
         functionName='function'
         functionAppSku='Y1'
         functionAppSkuFamily='Y'
         functionAppSkuTier='Dynamic'
         keyVaultOwnerUserId='owner1SID'
         location='eastus' 
         storageSku='Standard_LRS'
         serviceConnectionName='<yourServiceConnectionName>' 
         subscriptionIdDev='<yourSubscriptionId>' 
         subscriptionNameDev='<yourAzureSubscriptionName>' 
         resourceGroupNameDev='rg-lll-pyocr-dev'
         subscriptionIdProd='<yourProdSubscriptionId>' 
         subscriptionNameProd='<yourProdAzureSubscriptionName>' 
         resourceGroupNameProd='rg-lll-pyocr-prod'
```
