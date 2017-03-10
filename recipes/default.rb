include_recipe 'nagios'

package 'nagios-plugins-ping'
package 'nagios-plugins-ssh'
package 'nagios-plugins-by_ssh'

## Nodes
hostgroups = %w(dev prod)
hostgroups.each { |h| Nagios::Hostgroup.create(h) }

# Chef Search would be used here instead of my test nodes

test_nodes = node['test_nodes']

test_nodes.each do |_n, conf|
  name = conf['fqdn']
  hg   = name =~ /^prod/ ? 'prod' : 'dev'

  nagios_host conf['fqdn'] do
    options 'address' => conf['ipaddress'],
            'hostgroups' => [hg]
  end
end

## Commands

nagios_command 'check_host_alive' do
  options 'command_line' => '$USER1$/check_ping -H $HOSTADDRESS$ -w 2000,80% -c 3000,100% -p 1 --use-ipv4'
end

nagios_command 'check_ssh' do
  options 'command_line' => '$USER1$/check_ssh $HOSTADDRESS$'
end

# assuming fping is installed, since all this is chef-controlled

# TODO: this is ugly, cleanup
nag_ssh_user = node['test']['usr']
nag_ssh_user_priv_key = "#{node['nagios']['conf_dir']}/#{nag_ssh_user}.priv"

cookbook_file nag_ssh_user_priv_key do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode '400'
  source "ssh_keys/#{nag_ssh_user}.rsa"
end

nagios_command 'check_yahoo' do
  options 'command_line' => [
    '$USER1$/check_by_ssh -H $HOSTADDRESS$',
    '-C "/usr/sbin/fping www.yahoo.com"',
    '-p 22 --use-ipv4',
    '-o StrictHostKeyChecking=no -E',
    "-l #{nag_ssh_user} -i #{nag_ssh_user_priv_key}"
  ].join(' ')
end

## Services

nagios_service 'check_ssh' do
  options 'hostgroup_name' => 'all', # comes as part of the community cookbook
          'check_command'  => 'check_ssh'
end

hostgroups.each do |h|
  nagios_service 'check_internet_connectivity' do
    options 'hostgroup_name' => h,
            'check_command'  => 'check_yahoo'
  end
end
