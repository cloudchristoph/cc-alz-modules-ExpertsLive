// Defines our global environment standards

// Types, that enforce the usage of the correct values
@export()
@description('The environment for the application')
type environmentType = ('dev' | 'test' | 'prod')

@export()
@description('The location for the application')
type locationType = ('westeurope' | 'germanywestcentral')

@export()
@minLength(3)
@maxLength(15)
@description('The name of the workload - between 3 and 15 characters')
type workloadNameType = string

@export()
@description('Workload Information')
type workloadInfoType = {
  name: workloadNameType
  environment: environmentType
  location: locationType
  owner: string
  costcenter: string
}

// Constants, that define the global environment
@export()
@description('Central Firewall IP Address in the Hub')
var centralFirewallIP = '10.20.255.4'

@export()
@description('The Virtual Network Resource ID of the Hub')
var hubVirtualNetworkResourceId = '/subscriptions/9336bb37-673a-489d-9d67-58b0ac0a7ee9/resourceGroups/rg-cc-connectivity/providers/Microsoft.Network/virtualNetworks/vnet-cc-hub-germanywestcentral'

@export()
@description('The Central Log Analytics Workspace Resource ID')
var centralLogAnalyticsWorkspaceResourceId = '/subscriptions/4bca19d2-912e-4ea7-bcb8-6aaa0ca54338/resourceGroups/rg-cc-logging/providers/Microsoft.OperationalInsights/workspaces/cc-log-analytics'

@export()
@description('The Central Log Analytics Workspace ID - not the full resource ID')
var centralLogAnalyticsWorkspaceId = '4b9ccbf5-63a4-4a5e-af04-ca1de55679c3'

// Helper Functions
@export()
@description('Get the Tag object with additional tags')
func getTags(workload workloadInfoType, tags object) object =>
  union(tags, {
    environment: workload.environment
    workload: workload.name
    owner: workload.owner
    costcenter: workload.costcenter
  })

@export()
@description('Get the Resource ID of the Private DNS Zone')
func getPrivateDnsZoneResourceId(zoneName string) string =>
  '/subscriptions/9336bb37-673a-489d-9d67-58b0ac0a7ee9/resourceGroups/rg-cc-connectivity/providers/Microsoft.Network/privateDnsZones/${zoneName}'
