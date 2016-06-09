class apt::unattended_upgrades (
  $config_content = undef,
  $config_template = 'apt/50unattended-upgrades.erb',
  $mailonlyonerror = true,
  $mail_recipient = 'root',
  $blacklisted_packages = [],
  $ensure_version = present
) {

  package { 'unattended-upgrades':
    ensure  => $ensure_version
  }

  # For some reason, this directory is sometimes absent, which causes
  # unattended-upgrades to crash.
  file { '/var/log/unattended-upgrades':
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
    require => Package['unattended-upgrades'],
  }

  $file_content = $config_content ? {
    undef   => template($config_template),
    default => $config_content
  }

  apt_conf { '50unattended-upgrades':
    content     => $file_content,
    require     => Package['unattended-upgrades'],
    refresh_apt => false
  }
}
