Access the Nagios UI at [http://localhost:30080/](nagiosadmin/nagiosadmin)

`nagiosadmin/nagiosadmin`

## What?

- Wrapper cookbook around the [Nagios Chef Cookbook](https://github.com/schubergphilis/nagios)
- Multi node setup using test-kitchen
- Can test monitoring of real servers all in your local env

## How?

- Vagrant, Virtualbox and TestKitchen FTW! (with private networking)
- Using attributes with static private IPs (instead of chef search)
- Dummy test user for passwordless ssh
- Default check interval is set to 15 seconds for local dev (via .kitchen.yml)

## Issues

1. Converge twice on `primary` to get rid of `primary1-bento-centos-67` in Nagios

## Versions

```
$ sw_vers 
ProductName:	Mac OS X
ProductVersion:	10.12.3
BuildVersion:	16D32

$ chef -v
Chef Development Kit Version: 1.2.22
chef-client version: 12.18.31
delivery version: master (0b746cafed65a9ea1a79de3cc546e7922de9187c)
berks version: 2017-03-19T21:01:16.449619 1924] 2017-03-19T21:01:16.449800 1924] 2017-03-19T21:01:16.449932 1924] 2017-03-19T21:01:16.450053 1924] 2017-03-19T21:01:16.484330 1924] 2017-03-19T21:01:16.484480 1924] 5.6.0
kitchen version: 1.15.0

$ VirtualBox -h
Oracle VM VirtualBox Manager 5.1.14

$ vagrant --version
Vagrant 1.9.1
```

## Misc

- Nagios comes with a very handy config checker. If you mess up your Nagios config, chef run will dump

```
        * service[nagios] action reload
           
           ================================================================================
           Error executing action `reload` on resource 'service[nagios]'
           ================================================================================
           
           Mixlib::ShellOut::ShellCommandFailed
           ------------------------------------
           Expected process to exit with [0], but received '1'
           ---- Begin output of /sbin/service nagios reload ----
           STDOUT: Running configuration check... CONFIG ERROR!  Reload aborted.  Check your Nagios configuration.
           STDERR: 
           ---- End output of /sbin/service nagios reload ----
           Ran /sbin/service nagios reload returned 1
           
           Resource Declaration:
           ---------------------
           # In /tmp/kitchen/cache/cookbooks/nagios/recipes/default.rb
           
           200: service 'nagios' do
           201:   service_name nagios_service_name
           202:   supports :status => true, :restart => true, :reload => true
           203:   action [:enable, :start]
           204: end
           
           Compiled Resource:
           ------------------
           # Declared in /tmp/kitchen/cache/cookbooks/nagios/recipes/default.rb:200:in `from_file'
           
           service("nagios") do
             action [:enable, :start]
             supports {:status=>true, :restart=>true, :reload=>true}
```

Its very handy to `kitchen login primary1` and then run

```
$ nagios --verify-config /etc/nagios/conf.d/
```
