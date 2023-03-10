# --------------------------------
# Networking Configuration Build
#---------------------------------



# ----------------
# V-NET
# Li-NET
# ----------------
resource "azurerm_virtual_network" "li-net-v-net" {
    name                        = "li-net-v-net"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.li-nux_server_rg.name
    address_space               = ["10.0.0.0/16"]
}

# ----------------
# Subnets
# LoveNets
# ----------------
resource "azurerm_subnet" "linet_lovenet" {
  name                 = "linet_lovenet"
  resource_group_name  = azurerm_resource_group.li-nux_server_rg.name
  virtual_network_name = azurerm_virtual_network.li-net-v-net.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ----------------
# Public IPs 
# PubLIc I-Lis 
# ----------------
resource "azurerm_public_ip" "li-nux_server_pub_ip" {
   name = "li-nux_server_pub_ip"
   location = var.location
   resource_group_name = azurerm_resource_group.li-nux_server_rg.name
   allocation_method = "Dynamic"
   domain_name_label = "dnslibel"
}

# ----------------
# Network Interfaces
# Network Li-nterfaces
# ----------------
resource "azurerm_network_interface" "li-nux_server_linterface" {
   name = "li-nux_server_linterface"
   location = var.location
   resource_group_name = azurerm_resource_group.li-nux_server_rg.name

   ip_configuration {
       name = "internal"
       private_ip_address_allocation = "Dynamic"
       subnet_id = azurerm_subnet.linet_lovenet.id
       public_ip_address_id = azurerm_public_ip.li-nux_server_pub_ip.id
   }
}

# ----------------
# NSli Associations
# ----------------
resource "azurerm_subnet_network_security_group_association" "li-nux_nsli_association" {
    subnet_id                 = azurerm_subnet.linet_lovenet.id
    network_security_group_id = azurerm_network_security_group.lis_permission.id
}

# ----------------
# NSGs
# NSLi's
# ----------------
resource "azurerm_network_security_group" "lis_permission" {
   
   name = "lis_permission"
   resource_group_name = azurerm_resource_group.li-nux_server_rg.name
   location = azurerm_resource_group.li-nux_server_rg.location
  
   security_rule {
       name = "http"
       priority = 100
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "80"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

   security_rule {
       name = "https"
       priority = 200
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "443"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

   security_rule {
       name = "ssh"
       priority = 300
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "22"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }
}