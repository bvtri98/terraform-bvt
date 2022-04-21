output "my-rg-id" {
  value = data.azurerm_resource_group.my-rg.id
}

output "public_ip_address" {
  value = azurerm_windows_virtual_machine.my-windows-vm.public_ip_address
}