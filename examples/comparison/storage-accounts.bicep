// ***
// Comparison of Storage Accounts.
// ------------------------------------------------------------
// Deployed via default Azure Resource and via AVM Module with only the required parameters.
// ***

var storageAccountName1 = 'stacc1${uniqueString(subscription().id, resourceGroup().id)}'
var storageAccountName2 = 'stacc2${uniqueString(subscription().id, resourceGroup().id)}'

// Default resource
resource storageAccountDefault 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: storageAccountName1
  location: 'germanywestcentral'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// AVM Module
module storageAccountAVM 'br/public:avm/res/storage/storage-account:0.9.0' = {
  name: storageAccountName2
  params: {
    name: storageAccountName2
  }
}
