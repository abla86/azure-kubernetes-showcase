@description('Azure region for all showcase resources.')
param location string = resourceGroup().location

@description('Short, lowercase resource prefix. Azure Container Registry names require at least five characters.')
@minLength(5)
param namePrefix string = 'azkshowcase'

@description('AKS node count for the demonstration environment.')
param agentCount int = 2

@description('AKS node VM size. Review Azure pricing before deployment.')
param agentVmSize string = 'Standard_B2s'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${namePrefix}-logs'
  location: location
  properties: {
    retentionInDays: 30
  }
}

resource registry 'Microsoft.ContainerRegistry/registries@2026-03-01-preview' = {
  name: '${namePrefix}acr'
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
    dataEndpointEnabled: true
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      retentionPolicy: {
        days: 7
        status: 'enabled'
      }
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }
    }
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Enabled'
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: '${namePrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${namePrefix}-aks'
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
    agentPoolProfiles: [{
      name: 'system'
      count: agentCount
      vmSize: agentVmSize
      mode: 'System'
      osType: 'Linux'
      type: 'VirtualMachineScaleSets'
    }]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
    }
  }
}
