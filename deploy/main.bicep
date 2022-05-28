param environmentName string
param containerAppName string

param containerImage string
param containerPort int
param isExternalIngress bool = true
param location string = resourceGroup().location
param minReplicas int = 0
param transport string = 'auto'
param allowInsecure bool = false
param env array = []
param containerRegistry string = ''
param containerRegistryUsername string = ''
@secure()
param containerRegistryPassword string = ''

module containerApps 'container.bicep' = {
    name: 'containerApps'
    params: {
        location: location
        containerAppName: containerAppName
        containerImage: containerImage
        containerPort: containerPort
        environmentName: environmentName
        isExternalIngress: isExternalIngress
        minReplicas: minReplicas
        transport: transport
        allowInsecure: allowInsecure
        env: env
        containerRegistry:containerRegistry
        containerRegistryUsername:containerRegistryUsername
        containerRegistryPassword:containerRegistryPassword
    }
}

output fqdn string = containerApps.outputs.fqdn
