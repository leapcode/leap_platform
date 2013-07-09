class site_sshd::deploy_authorized_keys ( $keys ) {
  tag 'leap_authorized_keys'

  site_sshd::authorized_keys {'root':
    keys => $keys,
    home => '/root'
  }

}
