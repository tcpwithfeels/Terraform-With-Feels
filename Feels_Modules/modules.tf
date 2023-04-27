variable "resource_group_name" {}
variable "location" {}
variable "subnet_ids" {
  type = list(string)
}
<<<<<<< HEAD
variable "vm_name_prefix" {
  type = string
  default = "TCP_Feels-"
}
=======
variable "vm_name_prefix" {}
>>>>>>> origin
variable "vm_count" {
  default = 1
}

variable "vm_size" {
  default = "Standard_B1ls"
}

variable "init_script" {
<<<<<<< HEAD
  default = "echo"
=======
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
>>>>>>> origin
}

resource "azurerm_linux_virtual_machine" "TCP_Feels" {
  count                = var.vm_count
  name                 = "${var.vm_name_prefix}-${count.index}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  size                 = var.vm_size
<<<<<<< HEAD
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
=======
  network_interface_ids = [azurerm_network_interface.TCP_Feels[count.index].id]

  storage_os_disk {
    name              = "${var.vm_name_prefix}-${count.index}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
>>>>>>> origin
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
<<<<<<< HEAD
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
=======

  os_profile {
    computer_name  = "${var.vm_name_prefix}-${count.index}"
    admin_username = "adminuser"
    admin_password = "Passw0rd!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    custom_data = "${file("${path.module}/init.sh")}\n" + <<EOF
                #!/bin/bash
                sudo sed -i 's/{{ COUNTVAR }}/${count.index}/g' /var/www/html/index.nginx-debian.html
                EOF
>>>>>>> origin
  }
}