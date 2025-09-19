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
  copy_aliases  = false

  lifecycle {
    ignore_changes = [aliases]
  }
}



resource "lxd_instance" "instance" {
  for_each = { for instance in var.instances : instance.client_config.computer_title => instance }

  name = each.value.client_config.computer_title

  image = lxd_cached_image.image_name[
    coalesce(each.value.image_alias, each.value.fingerprint, var.image_alias, var.fingerprint)
  ].fingerprint

  profiles = compact(coalesce(each.value.profiles, var.profiles))

  type = coalesce(each.value.instance_type, var.instance_type)

  config = each.value.lxd_config != null ? each.value.lxd_config : {}


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
      "001-setup" = {
        command = [
          "/bin/bash",
          "-c",
          "${join(" && ", compact([
            "pro attach ${coalesce(each.value.pro_token, var.pro_token)}",
            (each.value.ppa != null && each.value.ppa != "" || var.ppa != null && var.ppa != "")
            ? "add-apt-repository ${coalesce(each.value.ppa, var.ppa)}"
            : null,
            (each.value.client_config.ssl_public_key == null || each.value.client_config.ssl_public_key == "")
            ? "echo | openssl s_client -connect ${coalesce(each.value.landscape_root_url, var.landscape_root_url)}:443 | openssl x509 | tee ${var.instance_landscape_server_ssl_public_key_path}"
            : null,
            "apt-get update && apt-get install -y ${coalesce(each.value.landscape_client_package, var.landscape_client_package)}",
            join(" ", compact([
              "sudo landscape-config --silent",
              each.value.client_config.bus != null && each.value.client_config.bus != "" ? "--bus ${each.value.client_config.bus}" : null,
              "--computer-title ${each.value.client_config.computer_title}",
              "--account-name ${coalesce(each.value.client_config.account_name, var.account_name)}",
              (each.value.client_config.registration_key != null && each.value.client_config.registration_key != "") || (var.registration_key != null && var.registration_key != "") ? "--registration-key ${coalesce(each.value.client_config.registration_key, var.registration_key)}" : null,
              "--url ${coalesce(each.value.client_config.url, "https://${coalesce(each.value.landscape_root_url, var.landscape_root_url)}/message-system")}",
              each.value.client_config.data_path != null && each.value.client_config.data_path != "" ? "--data-path ${each.value.client_config.data_path}" : null,
              each.value.client_config.log_dir != null && each.value.client_config.log_dir != "" ? "--log-dir ${each.value.client_config.log_dir}" : null,
              each.value.client_config.log_level != null && each.value.client_config.log_level != "" ? "--log-level ${each.value.client_config.log_level}" : null,
              each.value.client_config.pid_file != null && each.value.client_config.pid_file != "" ? "--pid-file ${each.value.client_config.pid_file}" : null,
              "--ping-url ${coalesce(each.value.client_config.ping_url, "http://${coalesce(each.value.landscape_root_url, var.landscape_root_url)}/ping")}",
              each.value.client_config.include_manager_plugins != null && each.value.client_config.include_manager_plugins != "" ? "--include-manager-plugins ${each.value.client_config.include_manager_plugins}" : null,
              each.value.client_config.include_monitor_plugins != null && each.value.client_config.include_monitor_plugins != "" ? "--include-monitor-plugins ${each.value.client_config.include_monitor_plugins}" : null,
              each.value.client_config.script_users != null && each.value.client_config.script_users != "" ? "--script-users ${each.value.client_config.script_users}" : null,
              "--ssl-public-key ${coalesce(each.value.server_ssl_public_key_path, var.instance_landscape_server_ssl_public_key_path)}",
              each.value.client_config.tags != null && each.value.client_config.tags != "" ? "--tags ${each.value.client_config.tags}" : null,
              each.value.client_config.access_group != null && each.value.client_config.access_group != "" ? "--access-group ${each.value.client_config.access_group}" : null,
              each.value.client_config.exchange_interval != null ? "--exchange-interval ${each.value.client_config.exchange_interval}" : null,
              each.value.client_config.urgent_exchange_interval != null ? "--urgent-exchange-interval ${each.value.client_config.urgent_exchange_interval}" : null,
              each.value.client_config.ping_interval != null ? "--ping-interval ${each.value.client_config.ping_interval}" : null,
              each.value.http_proxy != null && each.value.http_proxy != "" ? "--http-proxy ${each.value.http_proxy}" : null,
              each.value.https_proxy != null && each.value.https_proxy != "" ? "--https-proxy ${each.value.https_proxy}" : null
            ]))
          ]))}"
        ]
        trigger       = "once"
        record_output = true
        fail_on_error = true
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
