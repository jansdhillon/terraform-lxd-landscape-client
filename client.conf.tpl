[client]
%{ if bus != null && bus != "" ~}
bus = ${bus}
%{ endif ~}
computer_title = ${computer_title}
%{ if account_name != null && account_name != "" ~}
account_name = ${account_name}
%{ endif ~}
%{ if registration_key != null && registration_key != "" ~}
registration_key = ${registration_key}
%{ endif ~}
%{ if url != null && url != "" ~}
url = ${url}
%{ endif ~}
%{ if package_hash_id_url != null && package_hash_id_url != "" ~}
package_hash_id_url = ${package_hash_id_url}
%{ endif ~}
%{ if data_path != null && data_path != "" ~}
data_path = ${data_path}
%{ endif ~}
%{ if log_dir != null && log_dir != "" ~}
log_dir = ${log_dir}
%{ endif ~}
%{ if log_level != null && log_level != "" ~}
log_level = ${log_level}
%{ endif ~}
%{ if pid_file != null && pid_file != "" ~}
pid_file = ${pid_file}
%{ endif ~}
%{ if ping_url != null && ping_url != "" ~}
ping_url = ${ping_url}
%{ endif ~}
%{ if include_manager_plugins != null && include_manager_plugins != "" ~}
include_manager_plugins = ${include_manager_plugins}
%{ endif ~}
%{ if include_monitor_plugins != null && include_monitor_plugins != "" ~}
include_monitor_plugins = ${include_monitor_plugins}
%{ endif ~}
%{ if script_users != null && script_users != "" ~}
script_users = ${script_users}
%{ endif ~}
%{ if ssl_public_key != null && ssl_public_key != "" ~}
ssl_public_key = ${ssl_public_key}
%{ endif ~}
%{ if tags != null && tags != "" ~}
tags = ${tags}
%{ endif ~}
%{ if access_group != null && access_group != "" ~}
access_group = ${access_group}
%{ endif ~}
%{ if exchange_interval != null ~}
exchange_interval = ${exchange_interval}
%{ endif ~}
%{ if urgent_exchange_interval != null ~}
urgent_exchange_interval = ${urgent_exchange_interval}
%{ endif ~}
%{ if ping_interval != null ~}
ping_interval = ${ping_interval}
%{ endif ~}
