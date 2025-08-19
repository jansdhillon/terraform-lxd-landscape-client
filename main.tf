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
    "user.user-data" = local.cloud_init_contents
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
