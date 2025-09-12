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

variable "registration_key" {
  description = "Landscape Server registration key"
  type        = string
  sensitive   = true
}

variable "landscape_client_package" {
  type        = string
  description = "Landscape client package specification (ex. `landscape-client` or `landscape-client=23.02-0ubuntu1~22.04.5`)"
  default     = "landscape-client"
}

variable "instances" {
  type = set(object({
    image_alias              = optional(string)
    landscape_client_package = optional(string)
    client_config = object({
      computer_title           = string
      ping_interval            = optional(number)
      exchange_interval        = optional(number)
      urgent_exchange_interval = optional(number)
    })
    files = optional(list(object({
      content            = optional(string)
      source_path        = optional(string)
      target_path        = string
      uid                = optional(number)
      gid                = optional(number)
      mode               = optional(string, "0755")
      create_directories = optional(bool, false)
    })), [])
    additional_cloud_init = optional(string)
  }))
}

variable "image_alias" {
  type        = string
  default     = null
  description = "Default alias of image. Can be overridden per instance. Takes precedence over fingerprint if both are specified."
}
