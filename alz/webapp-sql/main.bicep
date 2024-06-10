metadata name = 'CC-ALZ-WebApp-with-SQL-DB'
metadata description = 'Definition of a WebApp spoke with SQL database for the CloudChristoph Company'
metadata version = '0.1.0'

targetScope = 'subscription'

import * as standards from '../../standards/standards.bicep'
import * as naming from '../../standards/naming.bicep'

// --- Parameters

param workloadInfo standards.workloadInfoType
param tags object = {}

param addressSpace string

param subnets array = [
  {
    name: 'webapp-inbound'
    addressPrefix: cidrSubnet(addressSpace, 26, 0)
  }
  {
    name: 'webapp-outbound'
    addressPrefix: cidrSubnet(addressSpace, 26, 1)
    delegations: [
      {
        name: 'Microsoft.Web/serverfarms'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
  {
    name: 'sql'
    addressPrefix: cidrSubnet(addressSpace, 26, 2)
  }
]

@minValue(3)
@description('Number of instances for the web app, must be at least 3 (to support Availability Zones)')
param webAppInstanceCount int = 3

@description('Deploy an empty database to the SQL server')
param deployEmptyDatabase bool = true

// --- Variables

var location = workloadInfo.location

var rgWebAppName = naming.getResourceGroupName(workloadInfo, 'webapp')
var rgDatabaseName = naming.getResourceGroupName(workloadInfo, 'database')

var webAppServerName = naming.getResourceName('appServicePlan', workloadInfo)
var webAppName = naming.getResourceName('webApp', workloadInfo)

var finalTags = standards.getTags(workloadInfo, tags)

// --- Components

module genericBase '../generic/main.bicep' = {
  name: 'module-genericBase'
  params: {
    workloadInfo: workloadInfo
    tags: tags
    addressSpace: addressSpace
    subnets: subnets
  }
}

module rgWebApp 'br/public:avm/res/resources/resource-group:0.2.3' = {
  name: 'module-rgWebApp'
  params: {
    name: rgWebAppName
    location: location
    tags: finalTags
  }
}

module rgDatabase 'br/public:avm/res/resources/resource-group:0.2.3' = {
  name: 'module-rgDatabase'
  params: {
    name: rgDatabaseName
    location: location
    tags: finalTags
  }
}

module webAppServer 'br/public:avm/res/web/serverfarm:0.1.1' = {
  name: 'module-webAppServer'
  dependsOn: [rgWebApp]
  scope: resourceGroup(rgWebAppName)
  params: {
    name: webAppServerName
    sku: {
      name: 'P0v3'
      tier: 'Premium'
      size: 'P0v3'
      family: 'P'
      capacity: webAppInstanceCount
    }
    kind: 'Linux'
    tags: finalTags
    zoneRedundant: true
    diagnosticSettings: [
      {
        workspaceResourceId: standards.centralLogAnalyticsWorkspaceResourceId
      }
    ]
  }
}

module webApp 'br/public:avm/res/web/site:0.3.5' = {
  name: 'module-webApp'
  dependsOn: [rgWebApp]
  scope: resourceGroup(rgWebAppName)
  params: {
    name: webAppName
    kind: 'app,linux'
    serverFarmResourceId: webAppServer.outputs.resourceId
    managedIdentities: {
      systemAssigned: true
    }
    virtualNetworkSubnetId: resourceId(
      subscription().subscriptionId,
      genericBase.outputs.networkResourceGroupName,
      'Microsoft.Network/virtualNetworks/subnets',
      genericBase.outputs.vnetName,
      subnets[1].name
    )
    privateEndpoints: [
      {
        subnetResourceId: resourceId(
          subscription().subscriptionId,
          genericBase.outputs.networkResourceGroupName,
          'Microsoft.Network/virtualNetworks/subnets',
          genericBase.outputs.vnetName,
          subnets[0].name
        )
        privateDnsZoneResourceIds: [
          standards.getPrivateDnsZoneResourceId('privatelink.azurewebsites.net')
        ]
      }
    ]
    diagnosticSettings: [
      {
        workspaceResourceId: standards.centralLogAnalyticsWorkspaceResourceId
      }
    ]
  }
}

module sqlServer 'br/public:avm/res/sql/server:0.4.0' = {
  name: 'module-sqlServer'
  dependsOn: [rgDatabase]
  scope: resourceGroup(rgDatabaseName)
  params: {
    name: naming.getResourceName('sqlDatabaseServer', workloadInfo)
    location: location
    tags: finalTags
    managedIdentities: {
      systemAssigned: true
    }
    administrators: {
      azureADOnlyAuthentication: true
      login: 'myspn'
      sid: genericBase.outputs.managedIdentityPrincipalId
      principalType: 'Application'
    }
    databases: (deployEmptyDatabase
      ? [
          {
            name: naming.getResourceName('sqlDatabase', workloadInfo)
            zoneRedundant: true
          }
        ]
      : null)
    privateEndpoints: [
      {
        subnetResourceId: resourceId(
          subscription().subscriptionId,
          genericBase.outputs.networkResourceGroupName,
          'Microsoft.Network/virtualNetworks/subnets',
          genericBase.outputs.vnetName,
          subnets[2].name
        )
        privateDnsZoneResourceIds: [
          standards.getPrivateDnsZoneResourceId('privatelink${environment().suffixes.sqlServerHostname}')
        ]
      }
    ]
  }
}

