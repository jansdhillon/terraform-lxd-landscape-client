locals {
  client_config_merged = {
    bus                     = var.client_config.bus
    computer_title          = var.client_config.computer_title
    account_name            = var.client_config.account_name
    registration_key        = var.client_config.registration_key
    fqdn                    = var.client_config.fqdn
    data_path               = var.client_config.data_path
    http_proxy              = var.client_config.http_proxy
    https_proxy             = var.client_config.https_proxy
    log_dir                 = var.client_config.log_dir
    log_level               = var.client_config.log_level
    pid_file                = var.client_config.pid_file
    ping_url                = coalesce(var.client_config.ping_url, "http://${var.client_config.fqdn}/ping")
    include_manager_plugins = var.client_config.include_manager_plugins
    include_monitor_plugins = var.client_config.include_monitor_plugins
    script_users            = var.client_config.script_users
    ssl_public_key          = var.client_config.ssl_public_key
    tags                    = var.client_config.tags
    url                     = coalesce(var.client_config.url, "https://${var.client_config.fqdn}/message-system")
    package_hash_id_url     = coalesce(var.client_config.package_hash_id_url, "https://${var.client_config.fqdn}/hash-id-databases")
  }

  landscape_client_config = templatefile("${path.module}/client.conf.tpl", local.client_config_merged)

  client_configs = [
    for i in range(var.instance_count) : merge(local.client_config_merged, {
      computer_title = "${local.client_config_merged.computer_title}-${i}"
    })
  ]

  cloud_init_configs = [
    for i in range(var.instance_count) : templatefile("${path.module}/cloud-init.yaml.tpl", {
      pro_token           = var.pro_token
      fqdn                = local.client_configs[i].fqdn
      conf_content        = templatefile("${path.module}/client.conf.tpl", local.client_configs[i])
      conf_path           = var.instance_landscape_config_path
      ppa                 = var.ppa
      ssl_public_key      = local.client_configs[i].ssl_public_key
      ssl_public_key_path = var.instance_landscape_server_ssl_public_key_path
      http_proxy          = local.client_configs[i].http_proxy
      https_proxy         = local.client_configs[i].https_proxy
    })
  ]

  cloud_init_contents = var.cloud_init_contents != null ? var.cloud_init_contents : local.cloud_init_configs[0]
  cloud_init_path     = var.cloud_init_path != null ? var.cloud_init_path : "${path.module}/cloud-init.yaml"
}
