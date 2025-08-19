resource "local_file" "cloud_init_user_data" {
  content  = local.landscape_client_cloud_init
  filename = var.cloud_init_path
}

resource "lxd_cached_image" "series" {
    source_image = var.source_image
    source_remote = var.source_remote
}

resource "lxd_instance" "lxd_vm" {
  count = var.instance_count
  name  = "${var.instance_name_prefix}-${count.index}"
  image = data.lxd_image.has_cves.fingerprint
  type  = "virtual-machine"
  
  depends_on = [terraform_data.ensure_lxd_image]
  
  config = var.config
  
  provisioner "local-exec" {
    command = <<-EOT
      lxc exec "${self.name}" --verbose -- cloud-init status --wait
    EOT
  }
}
