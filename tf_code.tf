# Specifies which provider plugin to use for the resources in the configuration.
provider "azurerm" {
  features {}
}

# Azure Resource Group
# a resource group is a logical container that holds related resources such as virtual machines, storage accounts, virtual networks, and more. 
# Resource groups are used to manage and organize resources for an application or environment, and they help simplify resource management and billing.
resource "azurerm_resource_group" "TCP_Feels_RG" {
  name     = "TCP_Feels-resource-group"
  location = "eastus"
}

# Virtual Network
resource "azurerm_virtual_network" "TCP_Feels_VNET" {
  name                = "TCP_Feels-vnet"
  address_space       = ["10.16.0.0/16"]
  location            = "${azurerm_resource_group.TCP_Feels_RG.location}"
  resource_group_name = "${azurerm_resource_group.TCP_Feels_RG.name}"
}

# Subnets
# Creating two subnets
resource "azurerm_subnet" "TCP_Feels-SUBNET-1" {
  name                 = "TCP_Feels-subnet-1"
  address_prefix       = "10.16.4.0/24"
  virtual_network_name = "${azurerm_virtual_network.TCP_Feels.name}"
  resource_group_name  = "${azurerm_resource_group.TCP_Feels_RG.name}"
}

resource "azurerm_subnet" "TCP_Feels-SUBNET-2" {
  name                 = "TCP_Feels-subnet-2"
  address_prefix       = "10.16.5.0/24"
  virtual_network_name = "${azurerm_virtual_network.TCP_Feels_VNET.name}"
  resource_group_name  = "${azurerm_resource_group.TCP_Feels_RG.name}"
}

# Module to create the virtual machines
# Modules are great to reuse code especially if you're creating the same types of Virtual Machines
# Module file 
module "TCP_Feels_VMs" {
  source                 = "./Feels_Modules"
  resource_group_name    = "${azurerm_resource_group.TCP_Feels_RG.name}"
  location               = "${azurerm_resource_group.TCP_Feels_RG.location}"
  subnet_ids             = ["${azurerm_subnet.TCP_Feels-1.id}", "${azurerm_subnet.TCP_Feels-2.id}"]
  vm_count               = 2
  vm_size                = "Standard_B1s"
  vm_name_prefix         = "TCP_Feels-vm"
}

# Create public IP for load balancer
resource "azurerm_public_ip" "TCP_Feels_PUB_IP" {
  name                = "TCP_Feels-lb-public-ip"
  location            = "${azurerm_resource_group.TCP_Feels_RG.location}"
  resource_group_name = "${azurerm_resource_group.TCP_Feels_RG.name}"
  allocation_method   = "Static"
}

# Load Balancer Creation
# For each VM that is created, create two backend addresses
# In additional create the same amount of probes in the backend address pool
# For each VM, also create rules to allow TCP 80
resource "azurerm_lb" "TCP_Feels_LB" {
  name                = "TCP_Feels-lb"
  location            = "${azurerm_resource_group.TCP_Feels_RG.location}"
  resource_group_name = "${azurerm_resource_group.TCP_Feels_RG.name}"

  frontend_ip_configuration {
    name                 = "TCP_Feels-lb-frontend-ip"
    public_ip_address_id = "${azurerm_public_ip.TCP_Feels_PUB_IP.id}"
  }

  dynamic "backend_address_pool" {
    for_each = module.TCP_Feels_VMs.vm_network_interface_ids
    content {
      name = "backend-pool-${backend_address_pool.key}"
      backend_address {
        nic_id = "${azurerm_network_interface.backend_nic[backend_address_pool.key].id}"
      }
    }
  }

  dynamic "probe" {
    for_each = module.TCP_Feels_VMs.vm_network_interface_ids
    content {
      name                = "TCP_Feels-probe-${probe.key}"
      protocol            = "Tcp"
      port                = 80
      interval_in_seconds = 5
      number_of_probes    = 1
    }
  }

  dynamic "rule" {
    for_each = module.TCP_Feels_VMs.vm_network_interface_ids
    content {
      name                   = "TCP_Feels-rule-${rule.key}"
      frontend_ip_configuration_name = "TCP_Feels-lb-frontend-ip"
      backend_address_pool_id = "${azurerm_lb_backend_address_pool.TCP_Feels[rule.key].id}"
      probe_id                = "${azurerm_lb_probe.TCP_Feels[rule.key].id}"
      protocol                = "Tcp"
      frontend_port           = 80
      backend_port            = 80
    }
  }

  # Output the public IP address of the load balancer
  output "lb_public_ip" {
    value = "${azurerm_public_ip.TCP_Feels.ip_address}"
  }
}
           
