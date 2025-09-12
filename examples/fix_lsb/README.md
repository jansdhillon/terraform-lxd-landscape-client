# Landscape Client LSB Fix

This example demonstrates how to use the `terraform-lxd-landscape-client` module to validate [an SRU](https://bugs.launchpad.net/landscape-client/+bug/2031036) fixes a bug where installing LSB modules caused an error when reporting packages on `jammy`.

## Prereqs

- LXD installed and configured
- Terraform installed
- Registration information for a Landscape Server account
- An Ubuntu Pro token
- Autoregistration enabled on Landscape Server

## Running the plan

1. Edit [`terraform.tfvars.example`](./terraform.tfvars.example) to match your desired config, then copy it to `terraform.tfvars`:

```sh
cp terraform.tfvars.example terraform.tfvars
```

2. Initialize and apply:

```sh
terraform init
terraform apply -auto-approve
```

3. View results:

```sh
printf "\njammy-lp2031036-proposed: \n"
lxc exec jammy-lp2031036-proposed -- sh -c '\
if [ -s /tmp/landscape/value-error-result.txt ]; then \
    cat /tmp/landscape/value-error-result.txt; \
else \
    echo "No errors!"; \
fi'

printf "\njammy-lp2031036-control (currently in archives): \n"
lxc exec jammy-lp2031036-control -- sh -c '\
if [ -s /tmp/landscape/value-error-result.txt ]; then \
    cat /tmp/landscape/value-error-result.txt; \
else \
    echo "No errors!"; \
fi'
```

...

```text
jammy-lp2031036-proposed: 
No errors!

jammy-lp2031036-control (currently in archives):
ValueError: too many values to unpack (expected 5)
```

As we can see from the error outputs, the bug has been fixed in the proposed version.

## Cleanup

```sh
terraform destroy -auto-approve
```
