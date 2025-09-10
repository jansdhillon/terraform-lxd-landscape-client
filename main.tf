resource "lxd_cached_image" "image_name" {
  for_each = {
    for instance in var.instances : instance.computer_title => {
      image = coalesce(
        instance.image_alias,
        instance.fingerprint,
        var.image_alias,
        var.fingerprint
      )
    }
  }

  source_image  = each.value.image
  source_remote = var.remote

  lifecycle {
    ignore_changes = [aliases]
  }
}

data "utils_deep_merge_yaml" "merged_cloud_init" {
  for_each = {
    for instance in var.instances : instance.computer_title => instance
    if instance.additional_cloud_init != null
  }

  input = [
    local.cloud_init_configs[each.key],
    each.value.additional_cloud_init
  ]
}

resource "lxd_instance" "instance" {
  for_each = { for instance in var.instances : instance.computer_title => instance }

  name  = each.value.computer_title
  image = lxd_cached_image.image_name[each.key].fingerprint
  type  = var.instance_type

  config = merge(var.lxd_config, {
    "user.user-data" = each.value.additional_cloud_init != null ? "#cloud-config\n${data.utils_deep_merge_yaml.merged_cloud_init[each.key].output}" : local.cloud_init_configs[each.key]
  })


  dynamic "device" {
    for_each = each.value.device != null ? [each.value.device] : []
    content {
      name       = device.value.name
      type       = device.value.type
      properties = device.value.properties
    }
  }

  timeouts = {
    create = var.timeout
  }

  execs = {
    "wait_for_cloud_init" = {
      command       = ["cloud-init", "status", "--wait"]
      enabled       = var.wait_for_cloud_init
      trigger       = "on_change"
      record_output = true
      fail_on_error = false
    }
  }

}
