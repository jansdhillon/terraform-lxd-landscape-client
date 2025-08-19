locals {
  landscape_client_cloud_init = <<-EOF
#cloud-config
apt:
  sources:
    trunk-testing-ppa:
      source: ppa:landscape/self-hosted-beta
packages:
  - landscape-client
ubuntu_advantage:
  token: ${var.pro_token}
ubuntu_pro:
  token: ${var.pro_token}
runcmd:
  - systemctl stop unattended-upgrades
  - systemctl disable unattended-upgrades
  - echo | openssl s_client -connect "${var.fqdn}:443" | openssl x509 | sudo tee /etc/landscape/server.pem
  - landscape-config --silent --account-name="standalone" --computer-title="$(hostname --long)" --url "https://${var.fqdn}/message-system" --ping-url "http://${var.fqdn}/ping" --script-users="${var.script_users}" --registration-key=${var.registration_key} --ssl-public-key="/etc/landscape/server.pem" --tags="${var.image}"
EOF

  cloud_init_contents = var.cloud_init_contents != null ? var.cloud_init_contents : local.landscape_client_cloud_init
}
