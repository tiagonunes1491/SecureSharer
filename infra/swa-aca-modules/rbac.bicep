@description('ID of the Azure Key Vault')
@minLength(1)
param keyVaultId string

@description('ID of the Azure Container Registry')
@minLength(1)
param acrId string

@description('UAMI Principal IDs array to give access to Key Vault and ACR')
param uamiId string 

@description('ACA subnet ID for deployment script networking')
param acaSubnetId string

@description('ID of the Storage Account for deployment scripts')
param storageAccountId string

var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'
var acrPullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
var networkContributorRoleId = '4d97b98b-1d4f-4787-a291-c67834d212e7'
var storageFileDataPrivilegedContributorRoleId = '69566ab7-960f-475b-8e7c-b3118f30c6bd'
// Existing resources

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  scope: resourceGroup()
  name: split(keyVaultId, '/')[8]
}


resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  scope: resourceGroup()
  name: split(acrId, '/')[8]
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  scope: resourceGroup()
  name: split(storageAccountId, '/')[8]
}

// Define the existing virtual network resource
resource acaVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  scope: resourceGroup()
  name: split(acaSubnetId, '/')[8]
}

// Define the existing subnet resource using the subnet's ID provided as parameter
resource acaSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: split(acaSubnetId, '/')[10]
  parent: acaVnet
}

resource kvRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
    scope: keyVault
    name: guid(keyVault.id, uamiId, 'KeyVaultSecretsUser')
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
      principalId: uamiId
      principalType: 'ServicePrincipal'
  }
}

// Make sure the principalId matches the Container App's managed identity
resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
    scope: acr
    name: guid(acr.id, uamiId, 'AcrPull')
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
      principalId: uamiId // This should be the Container App's managed identity principal ID
      principalType: 'ServicePrincipal'
  }
}

// Network Contributor role assignment for deployment script VNet integration
resource networkRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
    scope: acaSubnet
    name: guid(acaSubnet.id, uamiId, networkContributorRoleId)
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleId)
      principalId: uamiId
      principalType: 'ServicePrincipal'
  }
}

// Storage File Data Privileged Contributor role assignment for deployment scripts
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
    scope: storageAccount
    name: guid(storageAccount.id, uamiId, 'StorageFileDataPrivilegedContributor')
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageFileDataPrivilegedContributorRoleId)
      principalId: uamiId
      principalType: 'ServicePrincipal'
  }
}

// Outputs
output acrRoleAssignmentId string = acrRoleAssignment.id
output keyVaultRoleAssignmentId string = kvRoleAssignment.id
output networkRoleAssignmentId string = networkRoleAssignment.id
output storageRoleAssignmentId string = storageRoleAssignment.id
