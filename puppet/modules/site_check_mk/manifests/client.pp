class site_check_mk::client {

  $ssh_hash = hiera('ssh')
  $pubkey   = $ssh_hash['authorized_keys']['monitor']['key']
  $type     = $ssh_hash['authorized_keys']['monitor']['type']

  include site_apt::preferences::check_mk

  class { 'check_mk::agent':
    agent_package_name          => 'check-mk-agent',
    agent_logwatch_package_name => 'check-mk-agent-logwatch',
    method                      => 'ssh',
    homedir                     => '/etc/nagios/check_mk',
    register_agent              => false
  }

  file { '/root/.ssh/authorized_keys2':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => "command=\"/usr/bin/check_mk_agent\",no-port-forwarding,no-x11-forwarding,no-agent-forwarding,no-pty,no-user-rc, ${type} ${pubkey} monitor"
  }

}
