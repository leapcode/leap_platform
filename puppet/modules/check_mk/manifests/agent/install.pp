class check_mk::agent::install (
  $version = '',
  $filestore = '',
  $workspace,
  $agent_package_name,
  $agent_logwatch_package_name,
  $method = 'xinetd',
) {
  if $method == 'xinetd' {
    if ! defined($require_method) {
      package { 'xinetd':
        ensure => latest,
      }
    }
    $require_method = 'Package[\'xinetd\']'
  } else {
    $require_method = undef
  }

  if $filestore {
    if ! defined(File[$workspace]) {
      file { $workspace:
        ensure => directory,
      }
    }
    file { "${workspace}/check_mk-agent-${version}.noarch.rpm":
      ensure  => latest,
      source  => "${filestore}/check_mk-agent-${version}.noarch.rpm",
      require => $require_method,
    }
    file { "${workspace}/check_mk-agent-logwatch-${version}.noarch.rpm":
      ensure  => latest,
      source  => "${filestore}/check_mk-agent-logwatch-${version}.noarch.rpm",
      require => $require_method,
    }
    package { 'check_mk-agent':
      ensure   => latest,
      provider => 'rpm',
      source   => "${workspace}/check_mk-agent-${version}.noarch.rpm",
      require  => File["${workspace}/check_mk-agent-${version}.noarch.rpm"],
    }
    package { 'check_mk-agent-logwatch':
      ensure   => latest,
      provider => 'rpm',
      source   => "${workspace}/check_mk-agent-logwatch-${version}.noarch.rpm",
      require  => [
        File["${workspace}/check_mk-agent-logwatch-${version}.noarch.rpm"],
        Package['check_mk-agent'],
      ],
    }
  }
  else {
    if $version {
      $agent_package_version = $version
    } else {
      $agent_package_version = latest
    }

    package { 'check_mk-agent':
      ensure  => $agent_package_version,
      name    => $agent_package_name,
      require => $require_method,
    }
    package { 'check_mk-agent-logwatch':
      ensure  => $agent_package_version,
      name    => $agent_logwatch_package_name,
      require => Package['check_mk-agent'],
    }
  }
}
