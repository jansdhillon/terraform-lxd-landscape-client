variable "architecture" {
  type        = string
  default     = "amd64"
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

variable "client_config" {
  type = object({
    bus                     = optional(string, "session")
    computer_title          = string
    account_name            = string
    registration_key        = optional(string, "")
    fqdn                    = string
    data_path               = optional(string, "/var/lib/landscape/client")
    http_proxy              = optional(string)
    https_proxy             = optional(string)
    log_dir                 = optional(string, "/var/log/landscape")
    log_level               = optional(string, "info")
    pid_file                = optional(string, "/var/run/landscape-client.pid")
    ping_url                = optional(string)
    include_manager_plugins = optional(string, "ScriptExecution")
    include_monitor_plugins = optional(string, "ALL")
    script_users            = optional(string, "landscape,root")
    ssl_public_key          = optional(string, "/etc/landscape/server.pem")
    tags                    = optional(string, "")
    url                     = optional(string)
    package_hash_id_url     = optional(string, null)
  })
}

variable "cloud_init_path" {
  type    = string
  default = null
}

variable "cloud_init_contents" {
  type    = string
  default = null
}

variable "instance_count" {
  type    = number
  default = 1
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

variable "instance_name_prefix" {
  type        = string
  description = "The name of the instance to prepend to '-{index}'."
}

variable "instance_type" {
  type    = string
  default = "container"

  validation {
    condition     = contains(["virtual-machine", "container"], var.instance_type)
    error_message = "valid values are: virtual-machine, container"
  }
}

variable "image" {
  type        = string
  default     = "ubuntu"
  description = "The name of the image"
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
  default     = "ppa:landscape/self-hosted-beta"
  description = "PPA for Landscape client installation"
}

variable "source_image" {
  type        = string
  description = "Fingerprint or alias of image to pull."
}

variable "source_remote" {
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
