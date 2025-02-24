provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lab" {
  name     = "PenTestLab"
  location = "East US"
}

