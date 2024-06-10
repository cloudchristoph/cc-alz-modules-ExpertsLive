
// This module is based on module orginially written by Ronald Bosma (https://github.com/ronaldbosma) under the MIT License
// 
// Source: https://github.com/ronaldbosma/blog-code-examples/blob/master/apply-azure-naming-convention-using-bicep-functions/naming-conventions.bicep
// Blog Post: https://ronaldbosma.github.io/blog/2024/06/05/apply-azure-naming-convention-using-bicep-functions/
//
// Modified to comply with our naming conventions and use our standards module, also simplified.

import * as standards from './standards.bicep'

@export()
func getResourceName(
  resourceType string,
  workload standards.workloadInfoType,
) string => '${getPrefix(resourceType)}-${workload.name}-${workload.environment}-${abbreviateRegion(workload.location)}'

@export()
func getResourceGroupName(
  workload standards.workloadInfoType,
  groupName string
) string => 'rg-cc-${workload.name}-${groupName}-${workload.environment}-${abbreviateRegion(workload.location)}'

//=============================================================================
// Prefixes
//=============================================================================

func getPrefix(resourceType string) string => getPrefixMap()[resourceType]

// Prefixes for commonly used resources.
// Source for abbreviations: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
func getPrefixMap() object => {
  actionGroup: 'ag'
  alert: 'al'
  apiManagement: 'apim'
  applicationGateway: 'agw'
  applicationInsights: 'appi'
  appServiceEnvironment: 'ase'
  appServicePlan: 'asp'
  containerInstance: 'ci'
  functionApp: 'func'
  keyVault: 'kv'
  loadBalancerInternal: 'lbi'
  loadBalancerExternal: 'lbe'
  loadBalancerRule: 'rule'
  logAnalyticsWorkspace: 'log'
  logAnalyticsQueryPack: 'pack'
  logicApp: 'logic'
  managedIdentity: 'id'
  networkInterface: 'nic'
  networkSecurityGroup: 'nsg'
  publicIpAddress: 'pip'
  resourceGroup: 'rg'
  routeTable: 'rt'
  serviceBusNamespace: 'sbns'
  serviceBusQueue: 'sbq'
  serviceBusTopic: 'sbt'
  serviceBusTopicSubscription: 'sbts'
  sqlDatabase: 'db'
  sqlDatabaseServer: 'sql'
  staticWebapp: 'stapp'
  storageAccount: 'st'
  subnet: 'snet'
  synapseWorkspace: 'syn'
  virtualMachine: 'vm'
  virtualNetwork: 'vnet'
  webApp: 'app'

  // Custom prefixes not specified on the Microsoft site
  webtest: 'webtest'
}

//=============================================================================
// Regions
//=============================================================================

func abbreviateRegion(region string) string => getRegionMap()[region]

// Map Azure region name to Short Name (CAF) abbrevation taken from: https://www.jlaundry.nz/2022/azure_region_abbreviations/
func getRegionMap() object => {
  australiacentral: 'acl'
  australiacentral2: 'acl2'
  australiaeast: 'ae'
  australiasoutheast: 'ase'
  brazilsouth: 'brs'
  brazilsoutheast: 'bse'
  canadacentral: 'cnc'
  canadaeast: 'cne'
  centralindia: 'inc'
  centralus: 'cus'
  centraluseuap: 'ccy'
  eastasia: 'ea'
  eastus: 'eus'
  eastus2: 'eus2'
  eastus2euap: 'ecy'
  francecentral: 'frc'
  francesouth: 'frs'
  germanynorth: 'gn'
  germanywestcentral: 'gwc'
  italynorth: 'itn'
  japaneast: 'jpe'
  japanwest: 'jpw'
  jioindiacentral: 'jic'
  jioindiawest: 'jiw'
  koreacentral: 'krc'
  koreasouth: 'krs'
  northcentralus: 'ncus'
  northeurope: 'ne'
  norwayeast: 'nwe'
  norwaywest: 'nww'
  qatarcentral: 'qac'
  southafricanorth: 'san'
  southafricawest: 'saw'
  southcentralus: 'scus'
  southindia: 'ins'
  southeastasia: 'sea'
  swedencentral: 'sdc'
  swedensouth: 'sds'
  switzerlandnorth: 'szn'
  switzerlandwest: 'szw'
  uaecentral: 'uac'
  uaenorth: 'uan'
  uksouth: 'uks'
  ukwest: 'ukw'
  westcentralus: 'wcus'
  westeurope: 'we'
  westindia: 'inw'
  westus: 'wus'
  westus2: 'wus2'
  westus3: 'wus3'
  chinaeast: 'sha'
  chinaeast2: 'sha2'
  chinanorth: 'bjb'
  chinanorth2: 'bjb2'
  chinanorth3: 'bjb3'
  germanycentral: 'gec'
  germanynortheast: 'gne'
  usdodcentral: 'udc'
  usdodeast: 'ude'
  usgovarizona: 'uga'
  usgoviowa: 'ugi'
  usgovtexas: 'ugt'
  usgovvirginia: 'ugv'
  usnateast: 'exe'
  usnatwest: 'exw'
  usseceast: 'rxe'
  ussecwest: 'rxw'
}
