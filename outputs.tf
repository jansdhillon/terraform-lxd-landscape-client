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

output "setup_output" {
  value = {
    for idx, instance in lxd_instance.instance : idx => {
      code = instance.execs["001-setup"].exit_code
      out  = instance.execs["001-setup"].stdout
      err  = instance.execs["001-setup"].stderr
    }
  }
}
