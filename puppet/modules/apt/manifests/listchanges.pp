class apt::listchanges(
  $ensure_version = 'installed',
  $config = "apt/${::operatingsystem}/listchanges_${::debian_codename}.erb",
  $frontend = 'mail',
  $email = 'root',
  $confirm = '0',
  $saveseen = '/var/lib/apt/listchanges.db',
  $which = 'both'
){
  package { 'apt-listchanges': ensure => $ensure_version }

  file { '/etc/apt/listchanges.conf':
    content => template($apt::listchanges::config),
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['apt-listchanges'];
  }
}
