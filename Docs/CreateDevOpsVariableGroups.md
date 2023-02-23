# Set up an Azure DevOps Variable Groups

## Note: The Azure DevOps pipelines needs a variable group named "PythonDemo"

To create this variable group, customize and run this command in the Azure Cloud Shell:

``` bash
   az login
   az account set --subscription <yourAzureSubscriptionId>
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
         subscriptionName='<yourDevAzureSubscriptionName>' 
         subscriptionIdDev='<yourDevAzureSubscriptionId>' 
         subscriptionNameDev='<yourDevAzureSubscriptionName>' 
         resourceGroupNameDev='rg-pyocr-dev'
         subscriptionIdProd='<yourProdAzureSubscriptionId>' 
         subscriptionNameProd='<yourProdAzureSubscriptionName>' 
         resourceGroupNameProd='rg-pyocr-prod'
```
