@description('Azure region for the showcase resources.')
param location string = resourceGroup().location

@description('Stable resource-name prefix. Keep this short because the ACR name has a length constraint.')
param environmentName string = 'azure-kubernetes-showcase'

@description('AKS node VM size. This is intentionally a small example size for demonstration.')
param agentVmSize string = 'Standard_B2s'

@description('Number of AKS nodes for the showcase cluster.')
param agentCount int = 2

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${environmentName}-logs'
  location: location
  properties: {
    retentionInDays: 30
  }
}

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: replace('${environmentName}acr', '-', '')
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: '${environmentName}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${environmentName}-aks'
    agentPoolProfiles: [
      {
        name: 'system'
        count: agentCount
        vmSize: agentVmSize
        mode: 'System'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
}

resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(registry.id, aks.id, 'acrpull')
  scope: registry
  properties: {
    principalId: aks.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    )
  }
}

output registryName string = registry.name
output logWorkspaceName string = logAnalytics.name
output aksName string = aks.name
output aksResourceId string = aks.id
