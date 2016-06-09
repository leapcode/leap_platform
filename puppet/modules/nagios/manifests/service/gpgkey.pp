# define a gpgkey to be watched
define nagios::service::gpgkey(
  $ensure         = 'present',
  $warning        = '14',
  $key_info       = undef,
  $check_interval = 60,
){
  validate_slength($name,40,40)
  require ::nagios::plugins::gpg
  $gpg_home = $nagios::plugins::gpg::gpg_home
  $gpg_cmd  = "gpg --homedir ${gpg_home}"

  exec{"manage_key_${name}":
    user  => nagios,
    group => nagios,
  }
  nagios::service{
    "check_gpg_${name}":
      ensure => $ensure;
  }

  if $ensure == 'present' {
    Exec["manage_key_${name}"]{
      command => "${gpg_cmd} --keyserver hkps://hkps.pool.sks-keyservers.net --keyserver-options ca-cert-file=${gpg_home}/sks-keyservers.netCA.pem --recv-keys ${name}",
      unless  => "${gpg_cmd} --list-keys ${name}",
      before  => Nagios::Service["check_gpg_${name}"],
    }

    Nagios::Service["check_gpg_${name}"]{
      check_command  => "check_gpg!${warning}!${name}",
      check_interval => $check_interval,
    }
    if $key_info {
      Nagios::Service["check_gpg_${name}"]{
        service_description => "Keyfingerprint: ${name} - Info: ${key_info}",
      }
    } else {
      Nagios::Service["check_gpg_${name}"]{
        service_description => "Keyfingerprint: ${name}",
      }
    }
  } else {
    Exec["manage_key_${name}"]{
      command => "${gpg_cmd} --batch --delete-key ${name}",
      onlyif  => "${gpg_cmd} --list-keys ${name}",
      require => Nagios::Service["check_gpg_${name}"],
    }
  }
}
