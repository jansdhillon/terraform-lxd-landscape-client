resource "terraform_data" "image_type_trigger" {
  input = var.instance_type
}


resource "terraform_data" "cloud_init_trigger" {
  for_each = { for instance in var.instances : instance.client_config.computer_title => instance }

  input = each.value.additional_cloud_init != null ? data.utils_deep_merge_yaml.merged_cloud_init[each.key].output : local.cloud_init_configs[each.key]
}

resource "lxd_cached_image" "image_name" {
  for_each = toset([
    for instance in var.instances :
    coalesce(
      instance.image_alias,
      instance.fingerprint,
      instance.series,
      var.image_alias,
      var.fingerprint
    )
  ])
  source_image  = each.key
  source_remote = var.remote
  type          = var.instance_type
  aliases       = []

  lifecycle {
    ignore_changes       = [aliases]
    replace_triggered_by = [terraform_data.image_type_trigger]
  }
}

data "utils_deep_merge_yaml" "merged_cloud_init" {
  for_each = {
    for instance in var.instances : instance.client_config.computer_title => instance
    if instance.additional_cloud_init != null
  }

  input = [
    local.cloud_init_configs[each.key],
    each.value.additional_cloud_init
  ]

  append_list = true
  #deep_copy_list = true

}

resource "lxd_instance" "instance" {
  for_each = { for instance in var.instances : instance.client_config.computer_title => instance }

  name = each.value.client_config.computer_title
  image = lxd_cached_image.image_name[
    coalesce(
      each.value.image_alias,
      each.value.fingerprint,
      each.value.series,
      var.image_alias,
      var.fingerprint
    )
  ].fingerprint
  type = var.instance_type

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

  lifecycle {
    replace_triggered_by = [terraform_data.cloud_init_trigger[each.key]]
  }
}
