using '../../alz/webapp-sql/main.bicep'

param workloadInfo = {
  name: 'appx'
  location: 'germanywestcentral'
  costcenter: '23456'
  environment: 'prod'
  owner: 'appx-team'
}

param addressSpace = '10.22.0.0/24'
