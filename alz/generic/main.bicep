metadata name = 'CC-ALZ-Generic-Spoke'
metadata description = 'Definition of an generic spoke for the CloudChristoph Company'
metadata version = '0.1.0'

targetScope = 'subscription'

import * as standards from '../../standards/standards.bicep'
import * as naming from '../../standards/naming.bicep'

// --- Parameters

param workloadInfo standards.workloadInfoType
param tags object = {}

param addressSpace string = '10.21.0.0/24'

param subnets array = [
  {
    name: 'default'
    addressPrefix: addressSpace
  }
]

// --- Variables

var location = workloadInfo.location

var rgBaseName = naming.getResourceGroupName(workloadInfo, 'base')
var rgNetworkName = naming.getResourceGroupName(workloadInfo, 'network')
var vnetName = naming.getResourceName('virtualNetwork', workloadInfo)
var routeTableName = naming.getResourceName('routeTable', workloadInfo)
var networkSecurityGroupName = naming.getResourceName('networkSecurityGroup', workloadInfo)

var finalTags = standards.getTags(workloadInfo, tags)

// --- Resource Groups

module rgBase 'br/public:avm/res/resources/resource-group:0.2.3' = {
  name: 'module-rgBase'
  params: {
    name: rgBaseName
    location: location
    tags: finalTags
    lock: {
      kind: 'CanNotDelete'
      name: 'lock-rgBase'
    }
  }
}

module rgNetwork 'br/public:avm/res/resources/resource-group:0.2.3' = {
  name: 'module-rgNetwork'
  params: {
    name: rgNetworkName
    location: location
    tags: finalTags
    lock: {
      kind: 'CanNotDelete'
      name: 'lock-rgNetwork'
    }
  }
}

// --- Components - Base

module managedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.1' = {
  name: 'module-managedIdentity'
  scope: resourceGroup(rgBaseName)
  dependsOn: [rgBase]
  params: {
    name: naming.getResourceName('managedIdentity', workloadInfo)
    location: location
    tags: finalTags
  }
}

// --- Components - Network

module vnet 'br/public:avm/res/network/virtual-network:0.1.6' = {
  name: 'module-vnet'
  scope: resourceGroup(rgNetworkName)
  dependsOn: [
    rgNetwork
  ]
  params: {
    name: vnetName
    location: location
    tags: finalTags
    addressPrefixes: [addressSpace]
    dnsServers: [standards.centralFirewallIP]
    subnets: [
      for (subnet, index) in subnets: {
        name: subnet.name
        addressPrefix: subnet.addressPrefix
        routeTableResourceId: routeTable.outputs.resourceId
        networkSecurityGroupResourceId: networkSecurityGroup.outputs.resourceId
        delegations: (subnet.?delegations ?? [])
      }
    ]
    peerings: [
      {
        // Config for Spoke
        remoteVirtualNetworkId: standards.hubVirtualNetworkResourceId
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        useRemoteGateways: false

        // Config for Hub
        remotePeeringEnabled: true
        remotePeeringAllowForwardedTraffic: false
      }
    ]
    diagnosticSettings: [
      {
        workspaceResourceId: standards.centralLogAnalyticsWorkspaceResourceId
      }
    ]
  }
}

module routeTable 'br/public:avm/res/network/route-table:0.2.2' = {
  name: 'module-routeTable'
  scope: resourceGroup(rgNetworkName)
  dependsOn: [rgNetwork]
  params: {
    name: routeTableName
    location: location
    tags: finalTags
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: standards.centralFirewallIP
          hasBgpOverride: false
        }
      }
    ]
  }
}

module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.1.3' = {
  scope: resourceGroup(rgNetworkName)
  name: 'module-networkSecurityGroup'
  dependsOn: [rgNetwork]
  params: {
    name: networkSecurityGroupName
    location: location
    tags: finalTags
    securityRules: [
      {
        name: 'DenyOutboundInternet'
        properties: {
          priority: 1000
          direction: 'Outbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
        }
      }
      {
        name: 'DenyManagementPorts'
        properties: {
          priority: 200
          access: 'Deny'
          protocol: 'Tcp'
          direction: 'Outbound'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '3389'
            '22'
          ]
        }
      }
    ]
    diagnosticSettings: [
      {
        workspaceResourceId: standards.centralLogAnalyticsWorkspaceResourceId
      }
    ]
  }
}

// --- Defender for Cloud

module defenderForCloudConfig 'br/public:avm/ptn/security/security-center:0.1.0' = {
  name: 'module-defenderForCloudConfig'
  params: {
    scope: '/subscriptions/${subscription().subscriptionId}'
    workspaceResourceId: standards.centralLogAnalyticsWorkspaceResourceId
  }
}


// --- Outputs

output networkResourceGroupName string = rgNetwork.outputs.name
output vnetName string = vnet.outputs.name
output vnetResourceId string = vnet.outputs.resourceId
output subnetResourceIds array = vnet.outputs.subnetResourceIds

output subnets array = [for (subnet, index) in subnets: {
  name: subnet.name
  addressPrefix: subnet.addressPrefix
  resourceId: vnet.outputs.subnetResourceIds[index]
}]

output managedIdentityName string = managedIdentity.outputs.name
output managedIdentityPrincipalId string = managedIdentity.outputs.principalId
