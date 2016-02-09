# configures sshd, mosh, authorized keys and known hosts
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

  # we cannot use the 'hardened' parameter because leap_cli uses an
  # old net-ssh gem that is incompatible with the included
  # "KexAlgorithms curve25519-sha256@libssh.org",
  # see https://leap.se/code/issues/7591
  # therefore we don't use it here, but include all other options
  # that would be applied by the 'hardened' parameter
  # not all options are available on wheezy
  if ( $::lsbdistcodename == 'wheezy' ) {
    $tail_additional_options = 'Ciphers aes256-ctr
MACs hmac-sha2-512,hmac-sha2-256,hmac-ripemd160'
  } else {
    $tail_additional_options = 'Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr
MACs hmac-sha2-512,hmac-sha2-256,hmac-ripemd160'
  }

  ##
  ## SSHD SERVER CONFIGURATION
  ##
  class { '::sshd':
    manage_nagios           => false,
    ports                   => [ $ssh['port'] ],
    use_pam                 => 'yes',
    print_motd              => 'no',
    tcp_forwarding          => $ssh_config['AllowTcpForwarding'],
    manage_client           => false,
    use_storedconfigs       => false,
    tail_additional_options => $tail_additional_options,
    hostkey_type            => [ 'rsa', 'dsa', 'ecdsa' ]
  }
}
