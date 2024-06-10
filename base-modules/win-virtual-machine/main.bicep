metadata name = 'CC-ALZ-Base-Windows-VM'
metadata description = 'Definition of a Windows Virtual Machine for the CloudChristoph Company'
metadata version = '0.1.0'

param name string
param location string

@allowed(['small', 'medium', 'large'])
param sizeClass string = 'small'

@allowed(['WindowsServer2019', 'WindowsServer2022'])
param os string = 'WindowsServer2019'

param subnetId string

param zone int = 1

param environment string = 'dev'
param workload string = 'generic'


var vmSizeMap = {
  small: 'Standard_B2ms'
  medium: 'Standard_D2s_v3'
  large: 'Standard_D4s_v3'
}

var tags = {
  environment: environment
  workload: workload
}


module vm 'br/public:avm/res/compute/virtual-machine:0.4.2' = {
  name: 'mod-vm-${name}'
  params: {
    name: name
    tags: tags
    adminUsername: 'ccadmin'
    imageReference: {
      offer: 'WindowsServer'
      publisher: 'MicrosoftWindowsServer'
      sku: os
      version: 'latest'
    }
    nicConfigurations: [
      {
        name: 'nic-${name}'
        params: {
          name: 'nic-${name}'
          location: location
          ipConfigurations: [
            {
              name: 'ipconfig-${name}'
              params: {
                name: 'ipconfig-${name}'
                privateIPAllocationMethod: 'Dynamic'
                subnet: {
                  id: subnetId
                }
              }
            }
          ]
        }
      }
    ]
    osDisk: {
      diskSizeGB: 127
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Windows'
    vmSize: vmSizeMap[sizeClass]
    zone: zone
  }
}
