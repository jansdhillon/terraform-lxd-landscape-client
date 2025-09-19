variable "pro_token" {
  description = "Ubuntu Pro token"
  type        = string
  sensitive   = true
}

variable "account_name" {
  description = "Landscape Server account name"
  type        = string
}

variable "landscape_root_url" {
  description = "Landscape Server root URL"
  type        = string
}

variable "pro_token" {
  description = "Ubuntu Pro token"
  type        = string
  sensitive   = true
}

variable "registration_key" {
  description = "Landscape Server registration key"
  type        = string
  nullable    = true
  default     = ""
}

variable "landscape_client_package" {
  type        = string
  description = "Landscape Client debian package to install (ex. `landscape-client` or `landscape-client=23.02-0ubuntu1~22.04.5`)"
  default     = "landscape-client"
}

variable "instances" {
  type = set(object({
    client_config = object({
      account_name             = optional(string)
      access_group             = optional(string)
      bus                      = optional(string)
      computer_title           = string
      data_path                = optional(string)
      exchange_interval        = optional(number)
      include_manager_plugins  = optional(string)
      include_monitor_plugins  = optional(string)
      log_dir                  = optional(string)
      log_level                = optional(string)
      package_hash_id_url      = optional(string)
      pid_file                 = optional(string)
      ping_interval            = optional(number)
      ping_url                 = optional(string)
      registration_key         = optional(string)
      script_users             = optional(string)
      ssl_public_key           = optional(string)
      tags                     = optional(string)
      url                      = optional(string)
      urgent_exchange_interval = optional(number)
    })
    lxd_config = optional(map(string))
    devices = optional(list(object({
      name       = string
      type       = string
      properties = map(string)
    })), [])
    execs = optional(list(object({
      name          = string
      command       = list(string)
      enabled       = optional(bool, true)
      trigger       = optional(string, "on_change")
      environment   = optional(map(string))
      working_dir   = optional(string)
      record_output = optional(bool, false)
      fail_on_error = optional(bool, false)
      uid           = optional(number, 0)
      gid           = optional(number, 0)
    })), [])
    files = optional(list(object({
      content            = optional(string)
      source_path        = optional(string)
      target_path        = string
      uid                = optional(number)
      gid                = optional(number)
      mode               = optional(string, "0755")
      create_directories = optional(bool, false)
    })), [])
    fingerprint                = optional(string)
    http_proxy                 = optional(string)
    https_proxy                = optional(string)
    image_alias                = optional(string)
    instance_type              = optional(string)
    server_ssl_public_key_path = optional(string, "/etc/landscape/server.pem")
    landscape_client_package   = optional(string)
    landscape_root_url         = optional(string)
    ppa                        = optional(string)
    profiles                   = optional(list(string))
    pro_token                  = optional(string)
    remote                     = optional(string)
  }))
}

variable "image_alias" {
  type        = string
  default     = null
  description = "Default alias of image. Can be overridden per instance. Takes precedence over fingerprint if both are specified."
}
