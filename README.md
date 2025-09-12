# terraform-lxd-landscape-client

You need an Ubuntu Pro token to deploy this module, which you can get from <https://ubuntu.com/pro/dashboard>.

## Usage

```hcl
module "landscape-client" {
  source  = "jansdhillon/landscape-client/lxd"
  pro_token = "my-pro-token"
  account_name = "standalone"
  registration_key = "mykey"
  landscape_root_url = "landscape.example.com"
  ppa = "ppa:landscape/self-hosted-beta"

  instances = [
    {
      client_config = {
        computer_title = "client-0"
        log_level = "debug"
      }

      image_alias = "jammy"
    },
    {
      client_config = {
        computer_title = "client-1"
      }

      image_alias = "noble"

      files = [
        {
          source_path = "./my_script.py"
          target_path = "/tmp/my_script.py"
        }
      ]

      execs = [
        {
          name    = "say_hello"
          command = ["echo", "hello"]
        }
      ]

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
        - python3 /tmp/my_script.py
      EOT
    }
  ]

}
```

### Examples

See [`examples`](https://github.com/jansdhillon/terraform-lxd-landscape-client/tree/main/examples) for example applications of this module.

Additionally, see how this module can be used in a [Landscape Demo](https://github.com/jansdhillon/landscape-demo/blob/main/client/main.tf).
