# sample code to set some keys
# possibly a better location than nagios conf_dir but this is for demo only

nag_ssh_user = node['test']['usr']
nag_ssh_user_priv_key = node['test']['usr_ssh_priv_key']

cookbook_file nag_ssh_user_priv_key do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode '400'
  source "ssh_keys/#{nag_ssh_user}.rsa"
  sensitive true
end
