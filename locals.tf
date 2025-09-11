locals {
  fqdn             = var.fqdn
  account_name     = var.account_name
  registration_key = var.registration_key
  pro_token        = var.pro_token

  instance_configs = {
    for config in var.instances : config.client_config.computer_title => {
      bus                      = config.client_config.bus
      computer_title           = config.client_config.computer_title
      account_name             = coalesce(config.client_config.account_name, local.account_name)
      registration_key         = coalesce(config.client_config.registration_key, local.registration_key)
      fqdn                     = coalesce(config.fqdn, local.fqdn)
      data_path                = config.client_config.data_path
      http_proxy               = config.http_proxy
      https_proxy              = config.https_proxy
      log_dir                  = config.client_config.log_dir
      log_level                = config.client_config.log_level
      pid_file                 = config.client_config.pid_file
      ping_url                 = coalesce(config.client_config.ping_url, "http://${coalesce(config.fqdn, local.fqdn)}/ping")
      include_manager_plugins  = config.client_config.include_manager_plugins
      include_monitor_plugins  = config.client_config.include_monitor_plugins
      script_users             = config.client_config.script_users
      ssl_public_key           = config.client_config.ssl_public_key
      tags                     = config.client_config.tags
      access_group             = config.client_config.access_group
      url                      = coalesce(config.client_config.url, "https://${coalesce(config.fqdn, local.fqdn)}/message-system")
      package_hash_id_url      = coalesce(config.client_config.package_hash_id_url, "https://${coalesce(config.fqdn, local.fqdn)}/hash-id-databases")
      exchange_interval        = config.client_config.exchange_interval
      urgent_exchange_interval = config.client_config.urgent_exchange_interval
      ping_interval            = config.client_config.ping_interval
    }
  }

  cloud_init_configs = {
    for name, config in local.instance_configs : name => templatefile("${path.module}/cloud-init.yaml.tpl", {
      pro_token                      = var.pro_token
      fqdn                           = config.fqdn
      conf_content                   = templatefile("${path.module}/client.conf.tpl", config)
      conf_path                      = var.instance_landscape_config_path
      instance_landscape_config_path = var.instance_landscape_config_path
      ppa                            = var.ppa
      ssl_public_key                 = config.ssl_public_key
      ssl_public_key_path            = var.instance_landscape_server_ssl_public_key_path
      http_proxy                     = config.http_proxy
      https_proxy                    = config.https_proxy
    })
  }

}
