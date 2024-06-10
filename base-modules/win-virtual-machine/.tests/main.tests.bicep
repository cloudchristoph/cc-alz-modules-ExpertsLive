// Test with only required parameters
module test_required_params '../main.bicep' = {
  name: 'test_required_params'
  params: {
    name: 'test001'
    location: 'westeurope'
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', 'test001', 'test001')
  }
}
