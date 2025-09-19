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

}


resource "lxd_cached_image" "image_name" {
  for_each = {
    for instance in var.instances :
    coalesce(instance.image_alias, instance.fingerprint, var.image_alias, var.fingerprint) => {
      alias         = coalesce(instance.image_alias, var.image_alias)
      fingerprint   = instance.fingerprint != null && instance.fingerprint != "" ? instance.fingerprint : var.fingerprint
      instance_type = coalesce(instance.instance_type, var.instance_type)
      remote        = coalesce(instance.remote, var.remote)
    }...
  }

  source_image  = coalesce(each.value[0].alias, each.value[0].fingerprint)
  source_remote = each.value[0].remote
  type          = each.value[0].instance_type

  aliases = compact([each.value[0].alias])
}



resource "lxd_instance" "instance" {
  for_each = { for instance in var.instances : instance.client_config.computer_title => instance }

  name = each.value.client_config.computer_title

  image = lxd_cached_image.image_name[
    coalesce(each.value.image_alias, each.value.fingerprint, var.image_alias, var.fingerprint)
  ].fingerprint

  profiles = compact(coalesce(each.value.profiles, var.profiles))

  type = coalesce(each.value.instance_type, var.instance_type)

  config = merge(
    {
      "user.user-data" = each.value.additional_cloud_init != null ? "#cloud-config\n${data.utils_deep_merge_yaml.merged_cloud_init[each.key].output}" : local.cloud_init_configs[each.key]
    },
    each.value.additional_lxd_config != null ? each.value.additional_lxd_config : {}
  )


  dynamic "device" {
    for_each = each.value.devices != null ? each.value.devices : []
    content {
      name       = device.value.name
      type       = device.value.type
      properties = device.value.properties
    }
  }

  dynamic "file" {
    for_each = each.value.files != null ? each.value.files : []
    content {
      content            = file.value.content
      source_path        = file.value.source_path
      target_path        = file.value.target_path
      uid                = file.value.uid
      gid                = file.value.gid
      mode               = file.value.mode
      create_directories = file.value.create_directories
    }
  }

  timeouts = {
    create = var.timeout
  }

  execs = merge(
    {
      "wait_for_cloud_init" = {
        command       = ["cloud-init", "status", "--wait"]
        enabled       = var.wait_for_cloud_init
        trigger       = "on_change"
        record_output = true
        fail_on_error = false
      }
    },
    {
      for exec in(each.value.execs != null ? each.value.execs : []) : exec.name => {
        command       = exec.command
        enabled       = exec.enabled
        trigger       = exec.trigger
        environment   = exec.environment
        working_dir   = exec.working_dir
        record_output = exec.record_output
        fail_on_error = exec.fail_on_error
        uid           = exec.uid
        gid           = exec.gid
      }
    }
  )
}
