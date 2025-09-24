# terraform-lxd-landscape-client

You need an Ubuntu Pro token to deploy this module, which you can get from <https://ubuntu.com/pro/dashboard>.

## Usage

```hcl
module "landscape-client" {
  source  = "jansdhillon/landscape-client/lxd"
  pro_token = "my-pro-token"
  account_name = "standalone"
  landscape_root_url = "landscape.example.com"
  ppa = "ppa:landscape/self-hosted-beta"

  instances = [
    {
      client_config = {
        computer_title = "client-0"
        log_level      = "debug"
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
          content     = <<-EOT
          #!/usr/bin/env python3
          print("hi")
          EOT
          target_path = "/tmp/my_script.py"
        }
      ]

      execs = [
        {
          name    = "000-000-say-hello-before-register"
          command = ["echo", "hello"]
        },
        {
          name    = "005-run-script-after-register"
          command = ["python3", "/tmp/my_script.py"]
        }
      ]

      lxd_config = {
        "cloud-init.user-data" = <<-EOT
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
        EOT
      }
    }
  ]
}
```

### Examples

See [`examples`](https://github.com/jansdhillon/terraform-lxd-landscape-client/tree/main/examples) for example applications of this module.

Additionally, see how this module can be used in a [Landscape Demo](https://github.com/jansdhillon/landscape-demo/blob/main/client/main.tf).

### Setup

Landscape Client is setup entirely using LXD `exec`, but a cloud-init can be passed via the per-instance `lxd_config` option. Additional `execs` can be provided per instance. Note that they run in **alphabetical order** (hence the naming).

The setup composes of the following stages:

- `000-pro-attach`: Attaches the Ubuntu Pro token.
- `001-add-ppa`: Adds a PPA (optional).
- `002-ssl-handshake`: Performs the SSL handshake with Landscape Server and saves the public key to the specified destination (default: `/etc/landscape/server.pem`)
- `003-install`: Installs Landscape Client. By deafult, this will just be `landcape-client` but it can be overriden to specify a specific package (version).
- `004-config`: Calls `landscape-config` with the given `client_config` options and the `additional_landscape_config_args`. If successful, the client will be registered with Landscape Server.

The `execs_output` map output can be analyzed after a successful apply, for example:

```sh
terraform output -json execs_output | jq -r '."client-0"`
```

The `code`, `stdout`, and `stderr` attributes can be accessed on specific commands (accessed by name):

```sh
terraform output -json execs_output | jq -r '."client-0"."004-config".stderr'
```
