terraform {
  required_version = ">= 1.10"
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
    }
    utils = {
      source = "cloudposse/utils"
    }
  }
}
