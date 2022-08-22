//Parameters section
param vnetName string = 'vnet-test'
param vnetPrefix array = [
  '10.0.0.0/16'
]
param nsgName string = 'testNsg'
param subnetName string = 'subnet-test'
param subnetPrefix string = '10.0.0.0/24'
param pipSku string = 'Standard'
param pipallocationmethod string = 'Static'
param vmNamePrefix string = 'prod'
param vmSize string = 'Standard_B1ms'
param pcName string = 'vm-bicep-test'
param adminName string = 'test-user'
param adminPass string = '1Eppen_d0rf!'

//Variables section
var publicIpName = 'test-public-ip'
var nicName = 'test-interface'
var unqstr = uniqueString(resourceGroup().id)


//Resources section
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: vnetPrefix
    }
  }
}
resource securityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgName
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  parent: virtualNetwork
  name: subnetName
  dependsOn: [
    securityGroup
  ]
  properties: {
    addressPrefix: subnetPrefix
    networkSecurityGroup: {
      id: securityGroup.id
    }
  }
}
resource publicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName
  location: resourceGroup().location
  sku: {
    name: pipSku
  }
  properties: {
    publicIPAllocationMethod: pipallocationmethod
  }
}
resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: resourceGroup().location
  dependsOn: [
    publicIP
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
}
resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: '${vmNamePrefix}${unqstr}'
  location: resourceGroup().location
  dependsOn: [
    networkInterface
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: pcName
      adminUsername: adminName
      adminPassword: adminPass
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'osDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}
