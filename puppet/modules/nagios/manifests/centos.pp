# centos specific changes
class nagios::centos inherits nagios::base {

  package { [ 'nagios-plugins', 'nagios-plugins-smtp','nagios-plugins-http',
      'nagios-plugins-ssh', 'nagios-plugins-tcp', 'nagios-plugins-dig',
      'nagios-plugins-nrpe', 'nagios-plugins-load', 'nagios-plugins-dns',
      'nagios-plugins-ping', 'nagios-plugins-procs', 'nagios-plugins-users',
      'nagios-plugins-ldap', 'nagios-plugins-disk', 'nagios-plugins-swap',
      'nagios-plugins-nagios', 'nagios-plugins-perl', 'nagios-plugins-ntp',
      'nagios-plugins-snmp' ]:
      ensure => 'present',
      notify => Service['nagios'],
  }

  Service['nagios']{
    hasstatus => true,
  }

  file{
    'nagios_private':
      ensure  => directory,
      path    => "${nagios::base::cfg_dir}/private",
      purge   => true,
      recurse => true,
      notify  => Service['nagios'],
      owner   => root,
      group   => nagios,
      mode    => '0750';
  }
  File['nagios_resource_cfg']{
    path => "${nagios::base::cfg_dir}/private/resource.cfg",
  }
  if $nagios::allow_external_cmd {
    file{'/var/spool/nagios/cmd':
      ensure  => 'directory',
      require => Package['nagios'],
      owner   => apache,
      group   => nagios,
      mode    => '2660',
    }
  }
}
