variable "architecture" {
  type        = string
  default     = "x86_64"
  description = "CPU architecture"
}

variable "lxd_config" {
  type    = map(string)
  default = {}
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
}

variable "account_name" {
  type        = string
  description = "Landscape Server account name"
}

variable "fqdn" {
  type        = string
  description = "Landscape Server FQDN"
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
    fingerprint           = optional(string)
    image_alias           = optional(string)
    series                = optional(string)
    fqdn                  = optional(string)
    http_proxy            = optional(string)
    https_proxy           = optional(string)
    additional_cloud_init = optional(string)
    device = optional(object({
      name       = string
      type       = string
      properties = map(string)
    }))
  }))

  validation {
    condition = var.fingerprint != null || var.image_alias != null || alltrue([
      for instance in var.instances : instance.fingerprint != null || instance.image_alias != null || instance.series != null
    ])
    error_message = "Either var.fingerprint or var.image_alias must be set, or all instances must specify a fingerprint, image_alias, or series."
  }
}

variable "cloud_init_path" {
  type    = string
  default = null
}


variable "device" {
  type = object({
    name       = string
    type       = string
    properties = map(string)
  })
  default = null
}

variable "ephemeral" {
  type    = bool
  default = false
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
}

variable "profiles" {
  type    = list(string)
  default = null
}

variable "ppa" {
  type        = string
  description = "PPA for Landscape client installation"
  default     = null
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
  default     = "30m"
}
