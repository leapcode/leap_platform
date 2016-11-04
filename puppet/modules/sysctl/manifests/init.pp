class sysctl {

  file { '/etc/sysctl.conf':
    ensure => present,
    mode   => '0644',
    owner  => root,
    group  => root
  }
}

