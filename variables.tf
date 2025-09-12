variable "architecture" {
  type        = string
  default     = "x86_64"
  description = "CPU architecture"
}

variable "instance_landscape_config_path" {
  type        = string
  default     = "/etc/landscape/client.conf"
  description = "where the Landscape Client config will be written in each instance"
}

variable "instance_landscape_server_ssl_public_key_path" {
  type    = string
  default = "/etc/landscape/server.pem"
}

variable "registration_key" {
  type     = string
  nullable = true
  default  = ""
}

variable "account_name" {
  type        = string
  description = "Landscape Server account name"
}

variable "landscape_root_url" {
  type        = string
  description = "Landscape Server root URL"
}


variable "instances" {
  type = set(object({
    client_config = object({
      account_name             = optional(string)
      access_group             = optional(string)
      bus                      = optional(string)
      computer_title           = string
      registration_key         = optional(string)
      data_path                = optional(string)
      log_dir                  = optional(string)
      log_level                = optional(string)
      pid_file                 = optional(string)
      ping_url                 = optional(string)
      include_manager_plugins  = optional(string)
      include_monitor_plugins  = optional(string)
      script_users             = optional(string)
      ssl_public_key           = optional(string)
      tags                     = optional(string)
      url                      = optional(string)
      package_hash_id_url      = optional(string)
      exchange_interval        = optional(number)
      urgent_exchange_interval = optional(number)
      ping_interval            = optional(number)

    })

    fingerprint              = optional(string)
    image_alias              = optional(string)
    landscape_root_url       = optional(string)
    landscape_client_package = optional(string)
    http_proxy               = optional(string)
    https_proxy              = optional(string)
    additional_lxd_config    = optional(map(string))
    additional_cloud_init    = optional(string)
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
  }))

  validation {
    condition = var.fingerprint != null || var.image_alias != null || alltrue([
      for instance in var.instances : instance.fingerprint != null || instance.image_alias != null
    ])
    error_message = "Either var.fingerprint or var.image_alias must be set, or all instances must specify a fingerprint or image_alias."
  }
}

variable "instance_type" {
  type    = string
  default = "container"

  validation {
    condition     = contains(["virtual-machine", "container"], var.instance_type)
    error_message = "valid values are: virtual-machine, container"
  }
}

variable "pro_token" {
  type        = string
  description = "Ubuntu Pro token"
  sensitive   = true
}

variable "ppa" {
  type    = string
  default = null
}

variable "landscape_client_package" {
  type        = string
  description = "Landscape Client debian package to install (ex. `landscape-client` or `landscape-client=23.02-0ubuntu1~22.04.5`)"
  default     = "landscape-client"
}

variable "fingerprint" {
  type        = string
  default     = null
  description = "Default fingerprint of image. Can be overridden per instance."
}

variable "image_alias" {
  type        = string
  default     = null
  description = "Default alias of image. Can be overridden per instance. Takes precedence over fingerprint if both are specified."
}

variable "remote" {
  type    = string
  default = "ubuntu"
}

variable "wait_for_cloud_init" {
  type    = bool
  default = true
}

variable "timeout" {
  type        = string
  description = "duration string to wait for instances to deploy"
  default     = "10m"
}
