# Define the provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "TCP_Feels_RG" {
  name     = "TCP_Feels-resource-group"
  location = "eastus"
}

# Create virtual network
resource "azurerm_virtual_network" "TCP_Feels_VNET" {
  name                = "TCP_Feels-vnet"
  address_space       = ["10.16.0.0/16"]
  location            = "${azurerm_resource_group.TCP_Feels.location}"
  resource_group_name = "${azurerm_resource_group.TCP_Feels.name}"
}

# Create subnets
resource "azurerm_subnet" "TCP_Feels-SUBNET-1" {
  name                 = "TCP_Feels-subnet-1"
  address_prefix       = "10.16.4.0/24"
  virtual_network_name = "${azurerm_virtual_network.TCP_Feels.name}"
  resource_group_name  = "${azurerm_resource_group.TCP_Feels.name}"
}

resource "azurerm_subnet" "TCP_Feels-SUBNET-2" {
  name                 = "TCP_Feels-subnet-2"
  address_prefix       = "10.16.5.0/24"
  virtual_network_name = "${azurerm_virtual_network.TCP_Feels.name}"
  resource_group_name  = "${azurerm_resource_group.TCP_Feels.name}"
}

# Define the module to create the virtual machines
module "TCP_Feels_VMs" {
  source                 = "./modules/vms"
  resource_group_name    = "${azurerm_resource_group.TCP_Feels.name}"
  location               = "${azurerm_resource_group.TCP_Feels.location}"
  subnet_ids             = ["${azurerm_subnet.TCP_Feels-1.id}", "${azurerm_subnet.TCP_Feels-2.id}"]
  vm_count               = 2
  vm_size                = "Standard_B1s"
  vm_name_prefix         = "TCP_Feels-vm"
}

# Create public IP for load balancer
resource "azurerm_public_ip" "TCP_Feels_PUB_IP" {
  name                = "TCP_Feels-lb-public-ip"
  location            = "${azurerm_resource_group.TCP_Feels.location}"
  resource_group_name = "${azurerm_resource_group.TCP_Feels.name}"
  allocation_method   = "Static"
}

# Create load balancer
resource "azurerm_lb" "TCP_Feels_LB" {
  name                = "TCP_Feels-lb"
  location            = "${azurerm_resource_group.TCP_Feels.location}"
  resource_group_name = "${azurerm_resource_group.TCP_Feels.name}"

  frontend_ip_configuration {
    name                 = "TCP_Feels-lb-frontend-ip"
    public_ip_address_id = "${azurerm_public_ip.TCP_Feels.id}"
  }

  dynamic "backend_address_pool" {
    for_each = module.vms.vm_network_interface_ids
    content {
      name = "backend-pool-${backend_address_pool.key}"
      backend_address {
        nic_id = "${azurerm_network_interface.backend_nic[backend_address_pool.key].id}"
      }
    }
  }

  dynamic "probe" {
    for_each = module.vms.vm_network_interface_ids
    content {
      name                = "TCP_Feels-probe-${probe.key}"
      protocol            = "Tcp"
      port                = 80
      interval_in_seconds = 5
      number_of_probes    = 2
    }
  }

  dynamic "rule" {
    for_each = module.vms.vm_network_interface_ids
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
           
