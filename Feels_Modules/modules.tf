variable "resource_group_name" {}
variable "location" {}
variable "subnet_ids" {
  type = list(string)
}
variable "vm_name_prefix" {
  type = string
  default = "TCP_Feels-"
}
variable "vm_count" {
  default = 1
}

variable "vm_size" {
  default = "Standard_B1ls"
}

variable "init_script" {
  default = "echo"
}

resource "azurerm_linux_virtual_machine" "TCP_Feels" {
  count                = var.vm_count
  name                 = "${var.vm_name_prefix}-${count.index}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  size                 = var.vm_size
  network_interface_ids = [azurerm_network_interface.TCP_Feels-NIC[count.index].id]

  computer_name  = "TCP-Feels-COMPNAME-${count.index}"
  admin_username = "adminuser"
  admin_password = "Passw0rd!"
  disable_password_authentication = false
  custom_data = var.init_script

  os_disk {
    name              = "${var.vm_name_prefix}-${count.index}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "TCP_Feels-NIC" {
  count               = var.vm_count
  name                = "${var.vm_name_prefix}-${count.index}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "Internal-Network"
    subnet_id                     = var.subnet_ids[count.index % length(var.subnet_ids)]
    private_ip_address_allocation = "Dynamic"
  }
}