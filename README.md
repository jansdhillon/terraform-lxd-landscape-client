# terraform-lxd-landscape-client

You need an Ubuntu Pro token to deploy this module, which you can get from <https://ubuntu.com/pro/dashboard>.

## Usage

```sh
terraform init
```

```sh
terraform apply -auto-approve
```

## Examples

See [`examples`](https://github.com/jansdhillon/terraform-lxd-landscape-client/tree/main/examples) for example applications of this module.

Additionally, see how this module can be used in a [Landscape Demo](https://github.com/jansdhillon/landscape-demo/blob/main/client/main.tf).

### Basic Usage

```hcl
module "landscape-client" {
  source  = "jansdhillon/landscape-client/lxd"
  pro_token = "my-pro-token"
  account_name = "standalone"
  registration_key = "mykey"
  landscape_root_url = "landscape.example.com"

  instances = [
    {
      client_config = {
        computer_title = "client-0"
      }
      image_alias = "noble"
      additional_cloud_init = <<EOT
      #cloud-config
      apt:
        sources:
          fish-ppa:
            source: "ppa:fish-shell/release-4"

      package-upgrades: true
      packages:
        - fish
      users:
      - name: ubuntu
        shell: /usr/bin/fish
        sudo: ALL=(ALL) NOPASSWD:ALL
      runcmd:
        - echo 'hello'
      EOT
    }
  ]
  
}
```
