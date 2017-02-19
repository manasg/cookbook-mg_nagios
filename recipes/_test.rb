log "Chef worked! I am #{node['fqdn']} with address: #{node['addresses']}"
log 'Here are my all my ip addresses'

node['network']['interfaces'].each do |i, v|
  addresses = v['addresses'].select { |a, p| a if p['family'] =~ /inet/ }
  log "interface: #{i}, addresses: #{addresses.keys}"
end
