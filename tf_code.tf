# Specifies which provider plugin to use for the resources in the configuration.
provider "azurerm" {
  features {}
}

# Azure Resource Group
# a resource group is a logical container that holds related resources such as virtual machines, storage accounts, virtual networks, and more. 
# Resource groups are used to manage and organize resources for an application or environment, and they help simplify resource management and billing.
resource "azurerm_resource_group" "TCP_Feels-RG" {
  name     = "TCP_Feels-Resource-Group"
  location = "eastus"
}

# Virtual Network
resource "azurerm_virtual_network" "TCP_Feels-VNET" {
  name                = "TCP_Feels-VNET"
  address_space       = ["10.16.0.0/16"]
  location            = "${azurerm_resource_group.TCP_Feels-RG.location}"
  resource_group_name = "${azurerm_resource_group.TCP_Feels-RG.name}"
}

# Subnets
# Creating two subnets
resource "azurerm_subnet" "TCP_Feels-SUBNET" {
  name                 = "TCP_Feels-SUBNET"
  address_prefixes       = ["10.16.4.0/24"]
  virtual_network_name = "${azurerm_virtual_network.TCP_Feels-VNET.name}"
  resource_group_name  = "${azurerm_resource_group.TCP_Feels-RG.name}"
}

# Module to create the virtual machines
# Modules are great to reuse code especially if you're creating the same types of Virtual Machines
# Module file 
module "TCP_Feels_VMs" {
  source                 = "./Feels_Modules"
  resource_group_name    = "${azurerm_resource_group.TCP_Feels-RG.name}"
  location               = "${azurerm_resource_group.TCP_Feels-RG.location}"
  subnet_ids             = ["${azurerm_subnet.TCP_Feels-SUBNET.id}"]
  vm_count               = 2
  vm_size                = "Standard_B1s"
  vm_name_prefix         = "TCP_WITH_FEELS-"
  init_script = base64encode("./init.sh")

}

# "resource_group_name"
# "location"
# "subnet_ids"
# "vm_name_prefix"
# "vm_count"
# "vm_size"
# "init_script"
# resource "azurerm_virtual_machine" "example" {
#   for_each = var.vm_names
         
