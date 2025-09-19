variable "account_name" {
  type        = string
  description = "Landscape Server account name"
}

variable "architecture" {
  type        = string
  default     = "x86_64"
  description = "CPU architecture"
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

variable "instance_landscape_server_ssl_public_key_path" {
  type    = string
  default = "/etc/landscape/server.pem"

}

variable "instance_type" {
  type    = string
  default = "container"
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
    # NOTE: Scripts are run in alphabetical order. The setup script is 001-setup.
    execs = optional(list(object({
      name          = string
      command       = list(string)
      enabled       = optional(bool, true)
      trigger       = optional(string, "on_change") # on_change, on_start, or once
      environment   = optional(map(string))
      working_dir   = optional(string)
      record_output = optional(bool, false)
      fail_on_error = optional(bool, false)
      uid           = optional(number, 0) # root
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

  validation {
    condition = var.fingerprint != null || var.image_alias != null || alltrue([
      for instance in var.instances : instance.fingerprint != null || instance.image_alias != null
    ])
    error_message = "Either var.fingerprint or var.image_alias must be set, or all instances must specify a fingerprint or image_alias."
  }

  validation {
    condition = alltrue([
      for i in var.instances :
      contains(["virtual-machine", "container"], coalesce(i.instance_type, var.instance_type))
    ])
    error_message = "valid values are: virtual-machine, container"
  }
}

variable "landscape_client_package" {
  type        = string
  description = "Landscape Client debian package to install (ex. `landscape-client` or `landscape-client=23.02-0ubuntu1~22.04.5`)"
  default     = "landscape-client"
}

variable "landscape_root_url" {
  type        = string
  description = "Landscape Server root URL"
}

variable "ppa" {
  type    = string
  default = null
}

variable "pro_token" {
  type        = string
  description = "Ubuntu Pro token"
  sensitive   = true
}

variable "profiles" {
  type        = list(string)
  description = "Profiles to associate with all instances."
  default     = ["default"]
}

variable "registration_key" {
  type     = string
  nullable = true
  default  = ""
}

variable "remote" {
  type        = string
  default     = "ubuntu"
  description = "global image remote"
}

variable "timeout" {
  type        = string
  description = "duration string to wait for instances to deploy"
  default     = "10m"
}
