# Deploy generic plugins useful to all nodes
# nagios::plugin won't work to deploy a plugin
# because it complains with:
# Could not find dependency Package[nagios-plugins] …
# at /srv/leap/puppet/modules/nagios/manifests/plugin.pp:18
class site_nagios::plugins {

  file { [
    '/usr/local/lib', '/usr/local/lib/nagios',
    '/usr/local/lib/nagios/plugins' ]:
      ensure => directory;
    '/usr/local/lib/nagios/plugins/check_last_regex_in_log':
      source => 'puppet:///modules/site_nagios/plugins/check_last_regex_in_log',
      mode   => '0755';
  }
}
