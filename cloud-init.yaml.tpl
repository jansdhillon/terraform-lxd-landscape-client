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
%{ if http_proxy != null && http_proxy != "" ~}
  - export http_proxy="${http_proxy}"
%{ endif ~}
%{ if https_proxy != null && https_proxy != "" ~}
  - export https_proxy="${https_proxy}"
%{ endif ~}
%{ if fetch_ssl_cert ~}
  - echo | openssl s_client -connect "${fqdn}:443" | openssl x509 | sudo tee ${ssl_public_key_path}
  - landscape-config --silent -c ${conf_path} --ssl-public-key ${ssl_public_key_path}
%{ else ~}
  - landscape-config --silent -c ${conf_path} --ssl-public-key ${ssl_public_key_path}
%{ endif ~}
