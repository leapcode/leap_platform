# Install icli package and configure ncli aliases 
class site_nagios::server::icli {
  $nagios_hiera     = hiera('nagios')
  $environments     = $nagios_hiera['environments']

  package { 'icli':
    ensure => installed;
  }

  file { '/root/.bashrc':
    ensure => present;
  }

  file_line { 'icli aliases':
    path => '/root/.bashrc',
    line => 'source /root/.icli_aliases';
  }

  file { '/root/.icli_aliases':
    content => template("${module_name}/icli_aliases.erb"),
    mode    => '0644',
    owner   => root,
    group   => 0,
    require => Package['icli'];
  }
}