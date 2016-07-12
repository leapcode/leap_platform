class apt::cron::download inherits apt::cron::base {

  $action = "autoclean -y
dist-upgrade -d -y -o APT::Get::Show-Upgraded=true
"

  file { '/etc/cron-apt/action.d/4-dist-upgrade':
    ensure => absent,
  }

  file { '/etc/cron-apt/action.d/3-download':
    content => $action,
    require => Package[cron-apt],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }

  file { '/etc/cron-apt/config.d/MAILON':
    content => "MAILON=changes\n",
    require => Package[cron-apt],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }

}
