resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: '<UNIQUE_STORAGE_ACCOUNT_NAME>'
  location: 'westeurope'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
 }
