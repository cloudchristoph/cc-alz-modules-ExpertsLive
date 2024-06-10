using '../../alz/generic/main.bicep'

param workloadInfo = {
  name: 'example'
  location: 'germanywestcentral'
  costcenter: '12345'
  environment: 'dev'
  owner: 'cloudteam'
}

param addressSpace = '10.21.0.0/24'
