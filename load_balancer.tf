
# Create public IP for load balancer
resource "azurerm_public_ip" "TCP_Feels-PUB_IP" {
  name                = "TCP_Feels-lb-PUBLIC-IP"
  location            = "${azurerm_resource_group.TCP_Feels-RG.location}"
  resource_group_name = "${azurerm_resource_group.TCP_Feels-RG.name}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Load Balancer Creation
# For each VM that is created, create two backend addresses
# In additional create the same amount of probes in the backend address pool
# For each VM, also create rules to allow TCP 80
resource "azurerm_lb" "TCP_Feels-LB" {
  name                = "TCP_Feels-LB"
  location            = "${azurerm_resource_group.TCP_Feels-RG.location}"
  resource_group_name = "${azurerm_resource_group.TCP_Feels-RG.name}"
  sku = "Standard"

  frontend_ip_configuration {
        name                 = "TCP_Feels-LB-FRONTEND-IP"
        public_ip_address_id = "${azurerm_public_ip.TCP_Feels-PUB_IP.id}"   
    }
}   
# Need 
# backend address pool
resource "azurerm_lb_backend_address_pool" "TCP_Feels-LB_Backend_Pool" {
  loadbalancer_id = azurerm_lb.TCP_Feels-LB.id
  name            = "TCP_Feels-LB_Backend_Pool"
}

resource "azurerm_lb_backend_address_pool_address" "TCP_Feels-LB_Backend_Pool_ADDRESS" {
  name                    = "TCP_Feels-LB_Backend_Pool_ADDRESS"
  backend_address_pool_id = azurerm_lb_backend_address_pool.TCP_Feels-LB_Backend_Pool.id
  virtual_network_id      = azurerm_virtual_network.TCP_Feels-VNET.id
  ip_address              = "10.16.4.254"
}

# Probe
resource "azurerm_lb_probe" "TCP_Feels-LB_Probe" {
  loadbalancer_id       = azurerm_lb.TCP_Feels-LB.id
  name                  = "HTTP-probe"
  port                  = 80
  protocol              = "Tcp"
  number_of_probes      = 2
  interval_in_seconds   = 15
}

# LB rules
resource "azurerm_lb_rule" "TCP_Feels-LB_Rule" {
  loadbalancer_id                = azurerm_lb.TCP_Feels-LB.id
  name                           = "TCP_Feels-LB_Rule"
  protocol                       = "Tcp"
  frontend_port                  = 8800
  backend_port                   = 80
  backend_address_pool_ids      = [azurerm_lb_backend_address_pool.TCP_Feels-LB_Backend_Pool.id]
  frontend_ip_configuration_name = "TCP_Feels-LB-FRONTEND-IP"
}

# an output is a value that is computed by a resource and can be used by other resources or scripts. 
# Outputs are defined in the Terraform configuration file and can be accessed by other resources in the same Terraform configuration 
# OR by external scripts that consume the outputs.

# Output the public IP address of the load balancer
output "lb_public_ip" {
    value = "${azurerm_public_ip.TCP_Feels-PUB_IP.ip_address}"
}