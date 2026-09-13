using './main.bicep'

param location = resourceGroup().location
param namePrefix = 'azkshowcase'
param agentCount = 2
param agentVmSize = 'Standard_B2s'
