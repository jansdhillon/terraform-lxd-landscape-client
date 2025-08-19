#cloud-config
apt:
  sources:
    trunk-testing-ppa:
      source: ${ppa}
packages:
  - landscape-client
ubuntu_pro:
  token: ${pro_token}
write_files:
  - path: /etc/landscape/client.conf
    content: |
      ${indent(6, conf_content)}
runcmd:
  - systemctl stop unattended-upgrades
  - systemctl disable unattended-upgrades
  - echo | openssl s_client -connect "${fqdn}:443" | openssl x509 | sudo tee /etc/landscape/server.pem
  - landscape-config --silent -c /etc/landscape/client.conf
