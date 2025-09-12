module "landscape-client-benchmark" {
  source = "../.."

  pro_token          = var.pro_token
  account_name       = var.account_name
  landscape_root_url = var.landscape_root_url
  registration_key   = var.registration_key
  instances          = var.instances
  image_alias        = var.image_alias
}
