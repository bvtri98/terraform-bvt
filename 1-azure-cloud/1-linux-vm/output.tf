output "my-rg-id" {
  value = data.azurerm_resource_group.my-rg.id
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.my-linux-vm.public_ip_address
}