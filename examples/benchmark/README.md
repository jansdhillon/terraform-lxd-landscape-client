# Landscape Client Package Reporter Benchmark

This example demonstrates how to use the `terraform-lxd-landscape-client` module by benchmarking different versions of Landscape Client and validating [an SRU](https://bugs.launchpad.net/landscape-client/+bug/2099283).

[`benchmark_patch.py`](./benchmark_patch.py) instruments the `_compute_packages_changes` function in both Landscape Client instances to apply the profiling from the SRU Test Plan.

## Prereqs

- LXD installed and configured
- Terraform or OpenTofu
- Registration information for a Landscape Server account
- An Ubuntu Pro token
- Recommended: Autoregistration enabled on Landscape Server

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

3. View benchmark results:

```sh
printf "jammy-lp2099283-proposed: \n"
lxc exec jammy-lp2099283-proposed -- cat /var/lib/landscape/client/result.txt

printf "\njammy-lp2099283-control (currently in archives): \n"
lxc exec jammy-lp2099283-control -- cat /var/lib/landscape/client/result.txt
```

...

```text
jammy-lp2099283-propsed:

--------- Run on: 2025-09-11 21:52:34 ---------

         2935167 function calls (2935163 primitive calls) in 2.867 seconds

   Ordered by: cumulative time
   List reduced from 86 to 10 due to restriction <10>

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
        1    0.208    0.208    2.866    2.866 reporter.py:626(compute_packages_change_inner)
   124622    0.072    0.000    2.115    0.000 store.py:146(get_hash_id)
   124628    0.126    0.000    2.036    0.000 store.py:19(inner)
   124622    0.088    0.000    1.867    0.000 store.py:49(get_hash_id)
   124628    1.768    0.000    1.768    0.000 {method 'execute' of 'sqlite3.Cursor' objects}
        1    0.000    0.000    0.339    0.339 facade.py:183(get_locked_packages)
        1    0.022    0.022    0.339    0.339 facade.py:188(<listcomp>)
   125079    0.046    0.000    0.317    0.000 facade.py:446(is_package_installed)
   132241    0.026    0.000    0.261    0.000 package.py:453(__eq__)
   132241    0.126    0.000    0.236    0.000 package.py:423(_cmp)


CPU Time: 2.86s

jammy-lp2099283-control (currently in archives): 

--------- Run on: 2025-09-11 21:52:49 ---------

         3014815 function calls (3014811 primitive calls) in 28.603 seconds

   Ordered by: cumulative time
   List reduced from 137 to 10 due to restriction <10>

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
        1    0.173    0.173   28.603   28.603 reporter.py:626(compute_packages_change_inner)
   119172    0.166    0.000   25.689    0.000 package.py:726(origins)
   158761    0.204    0.000   25.509    0.000 package.py:316(__init__)
   158761   25.305    0.000   25.305    0.000 {method 'find_index' of 'apt_pkg.SourceList' objects}
   118258    0.075    0.000    2.208    0.000 store.py:146(get_hash_id)
   118264    0.134    0.000    2.125    0.000 store.py:19(inner)
   118258    0.092    0.000    1.940    0.000 store.py:49(get_hash_id)
   118264    1.837    0.000    1.837    0.000 {method 'execute' of 'sqlite3.Cursor' objects}
        1    0.000    0.000    0.303    0.303 facade.py:183(get_locked_packages)
        1    0.019    0.019    0.303    0.303 facade.py:188(<listcomp>)


CPU Time: 28.35s
```

## Cleanup

```sh
terraform destroy -auto-approve
```
