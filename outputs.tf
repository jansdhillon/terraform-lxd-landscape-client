output "ipv4_addresses" {
  value = {
    for idx, instance in lxd_instance.instance : idx => instance.ipv4_address
  }
}

output "status" {
  value = {
    for idx, instance in lxd_instance.instance : idx => instance.status
  }
}
