# https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure

# import resource group which existing on Azure portal
data "azurerm_resource_group" "my-rg" {
  name = "RG_Test_20220421"
}

# Create virtual network
resource "azurerm_virtual_network" "my-network" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "East Asia"
  resource_group_name = data.azurerm_resource_group.my-rg.name
}

# Create subnet
resource "azurerm_subnet" "my-subnet" {
  name                 = "my-subnet"
  resource_group_name  = data.azurerm_resource_group.my-rg.name
  virtual_network_name = azurerm_virtual_network.my-network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my-pub-ip" {
  name                = "my-pub-ip"
  location            = "East Asia"
  resource_group_name = data.azurerm_resource_group.my-rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my-nsg" {
  name                = "my-nsg"
  location            = "East Asia"
  resource_group_name = data.azurerm_resource_group.my-rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "my-nic" {
  name                = "my-nic"
  location            = "East Asia"
  resource_group_name = data.azurerm_resource_group.my-rg.name

  ip_configuration {
    name                          = "my-nic-conf"
    subnet_id                     = azurerm_subnet.my-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my-pub-ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "my-sg-ass" {
  network_interface_id      = azurerm_network_interface.my-nic.id
  network_security_group_id = azurerm_network_security_group.my-nsg.id
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "my-windows-vm" {
  name                = "mywindowsvm"
  resource_group_name = data.azurerm_resource_group.my-rg.name
  location            = "East Asia"
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.my-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}