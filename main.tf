# Declare the azure_credentials input variable
variable "azure_credentials" {
  description = "Azure credentials in JSON format"
  type        = string
  sensitive   = true
}

# Configure the Azure provider
provider "azurerm" {
  client_id       = jsondecode(var.azure_credentials)["clientId"]
  client_secret   = jsondecode(var.azure_credentials)["clientSecret"]
  subscription_id = jsondecode(var.azure_credentials)["subscriptionId"]
  tenant_id       = jsondecode(var.azure_credentials)["tenantId"]
}

# Configure the Azure features
provider "azurerm" {
  features {}
}

# Define the resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

# Define the virtual network
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

# Define the subnet
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define the network interface
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "example-ip-config"
    subnet_id                    = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Define the virtual machine
resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "password1234!" 

  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
}

# Outputs
output "vm_public_ip" {
  value = azurerm_linux_virtual_machine.example.public_ip_address
}

