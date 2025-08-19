# useful for defbugging
# resource "local_file" "landscape_config" {
#   count    = var.instance_count
#   content  = templatefile("${path.module}/client.conf.tpl", local.client_configs[count.index])
#   filename = "${path.module}/landscape-client-${count.index}.conf"
# }

# resource "local_file" "cloud_init_user_data" {
#   count    = var.instance_count
#   content  = local.cloud_init_configs[count.index]
#   filename = "${path.module}/cloud-init-${count.index}.yaml"
# }

resource "lxd_cached_image" "series" {
  source_image  = var.source_image
  source_remote = var.source_remote
}

resource "lxd_instance" "instance" {
  count = var.instance_count
  name  = "${var.instance_name_prefix}-${count.index}"
  image = lxd_cached_image.series.fingerprint
  type  = var.instance_type

  config = merge(var.lxd_config, {
    "user.user-data" = var.cloud_init_contents != null ? var.cloud_init_contents : local.cloud_init_configs[count.index]
  })

  timeouts = {
    create = var.timeout
  }

  execs = {
    "wait_for_cloud_init" = {
      command       = ["cloud-init", "status", "--wait"]
      enabled       = var.wait_for_cloud_init
      trigger       = "once"
      record_output = true
      fail_on_error = false
    }
  }
}
