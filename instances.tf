# ------------------------------------------
# Instances
# Creating the NGINX Server Li-nux Ma-chine
# ------------------------------------------

resource "azurerm_linux_virtual_machine" "li-nux_server" {
   size = "Standard_B1ls"
   name = "li-nux_server"

  # Resource Group
   resource_group_name = azurerm_resource_group.li-nux_server_rg.name
   location = azurerm_resource_group.li-nux_server_rg.location
   custom_data = base64encode(file("scripts/init.sh"))
   network_interface_ids = [
       azurerm_network_interface.li-nux_server_linterface.id
   ]

   source_image_reference {
       publisher = "Canonical"
       offer = "UbuntuServer"
       sku = "18.04-LTS"
       version = "latest"
   }

   os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
   }
   computer_name = "Li-nux Ma-chine"
   admin_username = "Superl1ma"
   admin_password = "Superl1ma"
   disable_password_authentication = false
#   depends_on = [azurerm_resource_group.webserver]
}