# Variables
$rgName = "myResourceGroup"
$location = "eastus"
$vnetName = "myVnet"
$vnetAddressPrefix = "10.0.0.0/16"
$subnetName = "mySubnet"
$subnetAddressPrefix = "10.0.1.0/24"
$nsgName = "myNsg"
$nicName = "myNic"
$vmName = "myVM"
$vmSize = "Standard_B1s"
$adminUsername = "myadmin"
$adminPassword = "mypassword"

# Create Resource Group
New-AzResourceGroup -Name $rgName -Location $location

# Create Virtual Network
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $vnetAddressPrefix

# Create Subnet
$subnet = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressPrefix -VirtualNetwork $vnet

# Add Subnet Configuration to Virtual Network
$vnet | Set-AzVirtualNetwork

# Create Network Security Group
$nsg = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName -Location $location

# Create NSG rule to allow RDP traffic
$nsg | Add-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Description "Allow RDP traffic" -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow

# Create NIC
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location -SubnetId $subnet.Id -NetworkSecurityGroupId $nsg.Id

# Create VM configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize

# Set VM credentials
$cred = New-Object System.Management.Automation.PSCredential ($adminUsername, (ConvertTo-SecureString $adminPassword -AsPlainText -Force))
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $cred

# Attach NIC to VM
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# Create VM
New-AzVM -ResourceGroupName $rgName -Location $location -VM $vmConfig
