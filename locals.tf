locals {
  landscape_root_url = var.landscape_root_url
  account_name       = var.account_name
  registration_key   = var.registration_key
  pro_token          = var.pro_token

  instance_configs = {
    for config in var.instances : config.client_config.computer_title => {
      bus                      = config.client_config.bus
      computer_title           = config.client_config.computer_title
      account_name             = coalesce(config.client_config.account_name, local.account_name)
      registration_key         = coalesce(config.client_config.registration_key, local.registration_key)
      landscape_root_url       = coalesce(config.landscape_root_url, local.landscape_root_url)
      data_path                = config.client_config.data_path
      http_proxy               = config.http_proxy
      https_proxy              = config.https_proxy
      log_dir                  = config.client_config.log_dir
      log_level                = config.client_config.log_level
      pid_file                 = config.client_config.pid_file
      ping_url                 = coalesce(config.client_config.ping_url, "http://${coalesce(config.landscape_root_url, local.landscape_root_url)}/ping")
      include_manager_plugins  = config.client_config.include_manager_plugins
      include_monitor_plugins  = config.client_config.include_monitor_plugins
      script_users             = config.client_config.script_users
      ssl_public_key           = config.client_config.ssl_public_key
      tags                     = config.client_config.tags
      access_group             = config.client_config.access_group
      url                      = coalesce(config.client_config.url, "https://${coalesce(config.landscape_root_url, local.landscape_root_url)}/message-system")
      package_hash_id_url      = coalesce(config.client_config.package_hash_id_url, "https://${coalesce(config.landscape_root_url, local.landscape_root_url)}/hash-id-databases")
      exchange_interval        = config.client_config.exchange_interval
      urgent_exchange_interval = config.client_config.urgent_exchange_interval
      ping_interval            = config.client_config.ping_interval
      landscape_client_package = coalesce(config.landscape_client_package, var.landscape_client_package)
    }
  }

  cloud_init_configs = {
    for name, config in local.instance_configs : name => templatefile("${path.module}/cloud-init.yaml.tpl", {
      pro_token                = var.pro_token
      landscape_root_url       = config.landscape_root_url
      landscape_config_content = templatefile("${path.module}/client.conf.tpl", config)
      landscape_config_path    = var.instance_landscape_config_path
      landscape_client_package = config.landscape_client_package
      ppa                      = var.ppa
      ssl_public_key           = config.ssl_public_key
      ssl_public_key_path      = var.instance_landscape_server_ssl_public_key_path
      http_proxy               = config.http_proxy
      https_proxy              = config.https_proxy
    })
  }

}
