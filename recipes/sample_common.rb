# this mimics a default role/recipe which would handle monitoring related housekeeping

log "Chef worked! I am #{node['fqdn']} with address: #{node['addresses']}"

log 'Here are my all my ip addresses'

node['network']['interfaces'].each do |i, v|
  addresses = v['addresses'].select { |a, p| a if p['family'] =~ /inet/ }
  log "interface: #{i}, addresses: #{addresses.keys}"
end

usr = node['test']['usr']
hd = "/home/#{usr}"
user usr do
  home hd
  shell '/bin/bash'
end

directory hd

directory "#{hd}/.ssh" do
  mode '700'
  owner usr
  group usr
end

cookbook_file "#{hd}/.ssh/authorized_keys2" do
  mode '600'
  source "ssh_keys/#{usr}.rsa.pub"
  owner usr
  group usr
end

include_recipe 'yum-epel'

package 'fping'

package 'nagios-plugins-disk'
