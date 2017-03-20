include_recipe 'nagios'

package 'nagios-plugins-ping'
package 'nagios-plugins-ssh'
package 'nagios-plugins-by_ssh'
package 'nagios-plugins-disk'

## Nodes

# Chef Search would be used here instead of my test target nodes
hostgroups = %w(dev prod)
hostgroups.each { |h| Nagios::Hostgroup.create(h) }

target_servers = node['target_servers']

target_servers.each do |_n, conf|
  name = conf['fqdn']
  hg   = name =~ /^prod/ ? 'prod' : 'dev'

  nagios_host conf['fqdn'] do
    options 'address' => conf['ipaddress'],
            'hostgroups' => [hg]
  end
end

# setup keys for passwordless ssh, used by check_by_ssh
include_recipe 'mg_nagios::_ssh'
nag_ssh_user = node['test']['usr']
nag_ssh_user_priv_key = node['test']['usr_ssh_priv_key']

## Commands

nagios_command 'chk_host_alive' do
  options 'command_line' => '$USER1$/check_ping -H $HOSTADDRESS$ -w 2000,80% -c 3000,100% -p 1 --use-ipv4'
end

nagios_command 'chk_ssh' do
  options 'command_line' => '$USER1$/check_ssh $HOSTADDRESS$'
end

# TODO: could set as attribute
chk_dir_space_cmd = '/usr/lib64/nagios/plugins/check_disk -u GB -w 20% -c 10% --path /home --path /var --timeout 3'

nagios_command 'chk_dir_space' do
  options 'command_line' => chk_dir_space_cmd
end

nagios_command 'chk_yahoo' do
  options 'command_line' => [
    '$USER1$/check_by_ssh -H $HOSTADDRESS$',
    '-p 22 --use-ipv4',
    '-o StrictHostKeyChecking=no -E',
    "-l #{nag_ssh_user} -i #{nag_ssh_user_priv_key}",
    '-C "/usr/sbin/fping www.yahoo.com"'
  ].join(' ')
end

nagios_command 'chk_by_ssh_dir_space' do
  options 'command_line' => [
    '$USER1$/check_by_ssh -H $HOSTADDRESS$',
    '-p 22 --use-ipv4',
    '-o StrictHostKeyChecking=no -E',
    "-l #{nag_ssh_user} -i #{nag_ssh_user_priv_key}",
    '-C "', chk_dir_space_cmd, '"'
  ].join(' ')
end

## Services

nagios_service 'svchk_ssh' do
  options 'hostgroup_name' => 'all', # comes as part of the community cookbook
          'check_command'  => 'chk_ssh'
end

# only for certain host groups

hostgroups.each do |h|
  nagios_service 'svcheck_internet_connectivity' do
    options 'hostgroup_name' => h,
            'check_command'  => 'chk_yahoo'
  end

  nagios_service 'svchk_by_ssh_dir_space' do
    options 'hostgroup_name' => h,
            'check_command'  => 'chk_by_ssh_dir_space'
  end
end

# for the nagios server itself

nagios_service 'svchk_dir_space' do
  options 'hostgroup_name' => node.chef_environment,
          'check_command' => 'chk_dir_space'
end
