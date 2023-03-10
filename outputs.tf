# ----------------
# Outputs
# Output for Li = <3
# ----------------

output "vnet_id" {
    value = azurerm_virtual_network.li-net-v-net.id
}

output "li-nux_server_priv_ip" {
    value = azurerm_linux_virtual_machine.li-nux_server.private_ip_address
}

output "li-nux_server_pub_ip" {
   value = azurerm_linux_virtual_machine.li-nux_server.public_ip_address
}

output "li-nux_server_li-bel" {
   value = azurerm_public_ip.li-nux_server_pub_ip.fqdn
}

#domain_name_label = "Libel"