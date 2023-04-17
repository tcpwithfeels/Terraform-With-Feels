variable "resource_group_name" {}
variable "location" {}
variable "subnet_ids" {
  type = list(string)
}
variable "vm_name_prefix" {}
variable "vm_count" {
  default = 1
}

variable "vm_size" {
  default = "Standard_B1ls"
}

variable "init_script" {
  default = file("${path.module}/init.sh")
}

resource "azurerm_network_interface" "TCP_Feels" {
  count               = var.vm_count
  name                = "${var.vm_name_prefix}-${count.index}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids[count.index % length(var.subnet_ids)]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "TCP_Feels" {
  count                = var.vm_count
  name                 = "${var.vm_name_prefix}-${count.index}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  size                 = var.vm_size
  network_interface_ids = [azurerm_network_interface.TCP_Feels[count.index].id]

  storage_os_disk {
    name              = "${var.vm_name_prefix}-${count.index}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.vm_name_prefix}-${count.index}"
    admin_username = "adminuser"
    admin_password = "Passw0rd!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    custom_data                     = var.init_script
  }
}