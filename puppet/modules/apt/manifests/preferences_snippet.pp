define apt::preferences_snippet (
  $priority = undef,
  $package = false,
  $ensure = 'present',
  $source = '',
  $release = '',
  $pin = ''
) {

  $real_package = $package ? {
    false   => $name,
    default => $package,
  }

  if $ensure == 'present' {
    if $apt::custom_preferences == false {
      fail('Trying to define a preferences_snippet with $custom_preferences set to false.')
    }

    if $priority == undef {
      fail('apt::preferences_snippet requires the \'priority\' argument to be set')
    }

    if !$pin and !$release {
      fail('apt::preferences_snippet requires one of the \'pin\' or \'release\' argument to be set')
    }
    if $pin and $release {
      fail('apt::preferences_snippet requires either a \'pin\' or \'release\' argument, not both')
    }
  }

  file { "/etc/apt/preferences.d/${name}":
    ensure => $ensure,
    owner  => root, group => 0, mode => '0644',
    before => Exec['apt_updated'];
  }

  case $source {
    '': {
      case $release {
        '': {
          File["/etc/apt/preferences.d/${name}"]{
            content => template('apt/preferences_snippet.erb')
          }
        }
        default: {
          File["/etc/apt/preferences.d/${name}"]{
            content => template('apt/preferences_snippet_release.erb')
          }
        }
      }
    }
    default: {
      File["/etc/apt/preferences.d/${name}"]{
        source => $source
      }
    }
  }
}
