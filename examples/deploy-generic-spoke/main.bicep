targetScope = 'subscription'

module genericSpoke '../../alz/generic/main.bicep' = {
  name: 'genericSpoke'
  params: {
    workloadInfo: {
      name: 'example'
      location: 'germanywestcentral'
      costcenter: '12345'
      environment: 'dev'
      owner: 'cloudteam'
    }
    addressSpace: '10.21.0.0/24'
  }
}
