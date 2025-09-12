#cloud-config
apt:
%{ if ppa != null && ppa != "" ~}
  sources:
    landscape_ppa:
      source: ${ppa}
%{ endif ~}
packages:
  - landscape-client
ubuntu_pro:
  token: ${pro_token}
write_files:
  - path: ${landscape_config_path}
    content: |
      ${indent(6, landscape_config_content)}
runcmd:
  - systemctl stop unattended-upgrades
  - systemctl disable unattended-upgrades
%{ if http_proxy != null && http_proxy != "" ~}
  - export http_proxy="${http_proxy}"
%{ endif ~}
%{ if https_proxy != null && https_proxy != "" ~}
  - export https_proxy="${https_proxy}"
%{ endif ~}
  - echo | openssl s_client -connect "${landscape_root_url}:443" | openssl x509 | sudo tee ${ssl_public_key_path}
  - landscape-config --silent -c ${landscape_config_path} --ssl-public-key ${ssl_public_key_path}
