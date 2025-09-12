module "landscape-client-benchmark" {
  source = "../.."

  pro_token        = var.pro_token
  account_name     = var.account_name
  fqdn             = var.fqdn
  registration_key = var.registration_key
  instances        = var.instances
}
