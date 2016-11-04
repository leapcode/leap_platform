class git::web::absent {

  package { 'gitweb':
    ensure => absent,
  } 

  file { '/etc/gitweb.d':
    ensure => absent,
    purge => true,
    force => true,
    recurse => true,
  } 
  file { '/etc/gitweb.conf':
    ensure => absent,
  } 
}

