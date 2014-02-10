class site_sshd {
  $ssh = hiera_hash('ssh')
  $hosts = hiera_hash('hosts')

  ##
  ## SETUP AUTHORIZED KEYS
  ##

  $authorized_keys = $ssh['authorized_keys']

  class { 'site_sshd::deploy_authorized_keys':
    keys => $authorized_keys
  }

  ##
  ## SETUP KNOWN HOSTS
  ##

  class { 'site_sshd::known_hosts':
    hosts => $hosts
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
}
