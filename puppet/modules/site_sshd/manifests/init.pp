class site_sshd {
  $ssh = hiera_hash('ssh')

  ##
  ## SETUP AUTHORIZED KEYS
  ##

  $authorized_keys = $ssh['authorized_keys']

  class { 'site_sshd::deploy_authorized_keys':
    keys => $authorized_keys
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
