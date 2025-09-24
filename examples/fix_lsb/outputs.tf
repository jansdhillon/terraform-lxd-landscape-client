output "ipv4_addresses" {
  value = module.verify_lsb_release_fixed.ipv4_addresses
}

output "execs_output" {
  value = module.verify_lsb_release_fixed.execs_output
  sensitive = true
}
