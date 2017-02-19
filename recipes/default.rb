include_recipe 'nagios'
package 'nagios-plugins-ping'
package 'nagios-plugins-ssh'

nagios_host 'srv1.test.manasg.com' do
  options 'address' => '172.28.128.3'
end

nagios_command 'check_host_alive' do
  options 'command_line' => '$USER1$/check_ping -H $HOSTADDRESS$ -w 2000,80% -c 3000,100% -p 1 --use-ipv4'
end

nagios_command 'check_ssh' do
  options 'command_line' => '$USER1$/check_ssh $HOSTADDRESS$'
end

nagios_service 'check_ssh' do
  options 'hostgroup_name' => 'all', # part of the cookbook
          'check_command'  => 'check_ssh'
end
