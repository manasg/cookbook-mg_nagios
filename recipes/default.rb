include_recipe 'nagios'
package 'nagios-plugins-ping'
package 'nagios-plugins-ssh'

test_nodes = node['test_nodes']

test_nodes.each do |_n, conf|
  nagios_host conf['fqdn'] do
    options 'address' => conf['ipaddress']
  end
end

nagios_command 'check_host_alive' do
  options 'command_line' => '$USER1$/check_ping -H $HOSTADDRESS$ -w 2000,80% -c 3000,100% -p 1 --use-ipv4'
end

nagios_command 'check_ssh' do
  options 'command_line' => '$USER1$/check_ssh $HOSTADDRESS$'
end

nagios_service 'check_ssh' do
  options 'hostgroup_name' => 'all', # comes as part of the community cookbook
          'check_command'  => 'check_ssh'
end
