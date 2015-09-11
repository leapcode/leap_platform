class site_sshd {
  $ssh        = hiera_hash('ssh')
  $ssh_config = $ssh['config']
  $hosts      = hiera('hosts', '')

  ##
  ## SETUP AUTHORIZED KEYS
  ##

  $authorized_keys = $ssh['authorized_keys']

  class { 'site_sshd::deploy_authorized_keys':
    keys => $authorized_keys
  }

  ##
  ## SETUP KNOWN HOSTS and SSH_CONFIG
  ##

  file {
    '/etc/ssh/ssh_known_hosts':
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template('site_sshd/ssh_known_hosts.erb');

    '/etc/ssh/ssh_config':
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template('site_sshd/ssh_config.erb');
  }

  ##
  ## OPTIONAL MOSH SUPPORT
  ##

  $mosh = $ssh['mosh']

  if $mosh['enabled'] {
    class { 'site_sshd::mosh':
      ensure => present,
      ports  => $mosh['ports']
    }
  }
  else {
    class { 'site_sshd::mosh':
      ensure => absent
    }
  }

  ##
  ## SSHD SERVER CONFIGURATION
  ##
  class { '::sshd':
    manage_nagios  => false,
    ports          => [ $ssh['port'] ],
    use_pam        => 'yes',
    hardened_ssl   => 'yes',
    print_motd     => 'no',
    tcp_forwarding => $ssh_config['AllowTcpForwarding'],
    manage_client  => false
  }
}
