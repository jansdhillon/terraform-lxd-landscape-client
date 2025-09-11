variable "pro_token" {
  description = "Ubuntu Pro token"
  type        = string
  sensitive   = true
}

variable "account_name" {
  description = "Landscape Server account name"
  type        = string
}

variable "fqdn" {
  description = "Landscape Server FQDN"
  type        = string
}

variable "registration_key" {
  description = "Landscape Server registration key"
  type        = string
  sensitive   = true
}

variable "instances" {
  type = set(object({
    image_alias = string
    client_config = object({
      computer_title           = string
      ping_interval            = number
      exchange_interval        = number
      urgent_exchange_interval = number
    })
    file = object({
      source_path = string
      target_path = string
    })
    additional_cloud_init = string
  }))
}
