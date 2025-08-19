output "ipv4_address" {
    value = resource.lxd_instance.lxd_vm.ipv4_address
}

output "status" {
    value = resource.lxd_instance.lxd_vm.status
}
