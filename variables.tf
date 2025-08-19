variable "account_name" {
  type        = string
  description = "Account name of Landscape Server, ex. standalone"
}

variable "architecture" {
  type        = string
  default     = "amd64"
  description = "CPU architecture"
}

variable "bus" {
  type    = string
  default = null
}

variable "container" {
  type    = string
  default = "container"
}

variable "config" {
  type = map(string)
  default = {}
}

variable "computer_title" {
  type = string
}


variable "instance_count" {
  type = number
}

variable "data_path" {
  type    = string
  default = null
}

# https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/instance
variable "device" {
  type = object({
    name       = string
    type       = string
    properties = map(string)
  })
}

variable "ephemeral" {
  type    = bool
  default = false
}

variable "fqdn" {
  type        = string
  description = "IP address or FQDN of Landscape Server to register with."
}

variable "include_manager_plugins" {
  type    = string
  default = "ALL"
}

variable "include_monitor_plugins" {
  type    = string
  default = "ALL"
}

variable "instance_name_prefix" {
  type        = string
  description = "The name of the instance to prepend to '-{index}'."
}

variable "instance_types" {
  type    = list(string)
  default = ["virtual-machine", "container"]
}

variable "instance_type" {
  type    = string
  default = "virtual-machine"

  validation {
    condition     = contains(var.instance_types, var.instance_type)
    error_message = "valid values are: ${join(", ", var.instance_types)}"
  }
}

variable "image" {
  type        = string
  default     = "ubuntu"
  description = "The name of the image on the defaul"
}

variable "image_fingerprint" {
  type    = string
  default = null
}

variable "source_image" {
  type = string
}

variable "source_remote" {
  type    = string
  default = "ubuntu"

  validation {
    condition     = var.source_remote != null && var.source_image != null
    error_message = "Source image "
  }
}


variable "log_dir" {
  type    = string
  default = null
}

variable "log_level" {
  type    = string
  default = null
}

variable "package_hash_id_url" {
  type    = string
  default = null
}

variable "pid_file" {
  type    = string
  default = null
}

variable "ping_url" {
  type    = string
  default = null
}

variable "pro_token" {
  type        = string
  description = "Ubuntu Pro token"
}

variable "profiles" {
  type    = list(string)
  default = null
}

variable "registration_key" {
  type        = string
  description = "Registration key for Landscape Server"
  default     = null
}

variable "remote" {
  type    = string
  default = "default"
}

variable "script_users" {
  type    = string
  default = "ALL"
}

variable "virtual_machine" {
  type    = string
  default = "virtual-machine"
}

variable "cloud_init_path" {
  type    = string
  default = "${path.module}/cloud-init.yaml"
}

variable "cloud_init_contents" {
  type    = string
  default = null
}
