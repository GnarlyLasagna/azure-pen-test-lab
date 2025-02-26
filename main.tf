
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Define the resource group
resource "azurerm_resource_group" "example-rg" {
  name     = "pen-testing-lab"
  location = "East US"
  tags = {
    environment = "lab"
  }
}

# Define the virtual network
resource "azurerm_virtual_network" "example-vnet" {
  name                = "example-vnet"
  location            = azurerm_resource_group.example-rg.location
  resource_group_name = azurerm_resource_group.example-rg.name
  address_space       = ["10.123.0.0/16"]
  tags = {
    environment = "lab"
  }
}

# Define the subnet
resource "azurerm_subnet" "example-subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example-rg.name
  virtual_network_name = azurerm_virtual_network.example-vnet.name
  address_prefixes     = ["10.123.1.0/24"]
}

# Define network security group
resource "azurerm_network_security_group" "example-sg" {
  name                = "testing-lab-security-group"
  location            = azurerm_resource_group.example-rg.location
  resource_group_name = azurerm_resource_group.example-rg.name

  security_rule {
    name                       = "lab-sec-rules"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

# Define subnet network security group association
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example-subnet.id
  network_security_group_id = azurerm_network_security_group.example-sg.id
}

# Define the public IP
resource "azurerm_public_ip" "example" {
  name                = "lab-public-ip"
  location            = azurerm_resource_group.example-rg.location
  resource_group_name = azurerm_resource_group.example-rg.name
  allocation_method   = "Dynamic"
  tags = {
    environment = "Production"
  }

}

# Define the network interface
resource "azurerm_network_interface" "nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.example-rg.location
  resource_group_name = azurerm_resource_group.example-rg.name

  ip_configuration {
    name                          = "example-ip-config"
    subnet_id                     = azurerm_subnet.example-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id # Attach Public IP
  }
}

# Define the virtual machine
resource "azurerm_linux_virtual_machine" "example" {
  name                            = "example-vm"
  location                        = azurerm_resource_group.example-rg.location
  resource_group_name             = azurerm_resource_group.example-rg.name
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  custom_data = filebase64("${path.module}/customdata.tpl")

  # Specify the SSH key for authentication
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azure-terraform-key.pub")
  }

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

