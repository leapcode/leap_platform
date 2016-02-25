# installs check-mk agent
class site_check_mk::agent {

  $ssh_hash = hiera('ssh')
  $pubkey   = $ssh_hash['authorized_keys']['monitor']['key']
  $type     = $ssh_hash['authorized_keys']['monitor']['type']


  # /usr/bin/mk-job depends on /usr/bin/time
  ensure_packages('time')

  class { 'site_apt::preferences::check_mk': } ->

  class { 'check_mk::agent':
    agent_package_name          => 'check-mk-agent',
    agent_logwatch_package_name => 'check-mk-agent-logwatch',
    method                      => 'ssh',
    homedir                     => '/etc/nagios/check_mk',
    register_agent              => false,
    requires                    => Package['time']
  } ->

  class { 'site_check_mk::agent::mrpe': } ->
  class { 'site_check_mk::agent::logwatch': } ->

  file {
    [ '/srv/leap/nagios', '/srv/leap/nagios/plugins' ]:
      ensure  => directory;
    '/usr/lib/check_mk_agent/local/run_node_tests.sh':
      source => 'puppet:///modules/site_check_mk/agent/local_checks/all_hosts/run_node_tests.sh',
      mode   => '0755';
  }

}
