# a wrapper for syncing a plugin
define nagios::plugin(
  $source = 'absent',
  $ensure = present,
){
  if $::hardwaremodel == 'x86_64' and $::operatingsystem != 'Debian' {
    $real_path = "/usr/lib64/nagios/plugins/${name}"
  }
  else {
    $real_path = "/usr/lib/nagios/plugins/${name}"
  }

  $real_source = $source ? {
    'absent' => "puppet:///modules/nagios/plugins/${name}",
    default => "puppet:///modules/${source}"
  }

  file{$name:
    ensure  => $ensure,
    path    => $real_path,
    source  => $real_source,
    tag     => 'nagios_plugin',
    require => Package['nagios-plugins'],
    owner   => 'root',
    group   => 0,
    mode    => '0755';
  }
}
