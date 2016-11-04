class check_mk::agent::config (
  $ip_whitelist    = '',
  $port,
  $server_dir,
  $keydir,
  $authdir,
  $authfile        = undef,
  $use_cache,
  $user,
  $method          = 'xinetd',
  $generate_sshkey = false,
  $sshuser         = undef,
  $hostname        = $::fqdn
) {
  if $use_cache {
    $server = "${server_dir}/check_mk_caching_agent"
  } else {
    $server = "${server_dir}/check_mk_agent"
  }

  case $method {
    'xinetd': {
      if $ip_whitelist {
        $only_from = join($ip_whitelist, ' ')
      } else {
        $only_from = undef
      }

      file { '/etc/xinetd.d/check_mk':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('check_mk/agent/check_mk.erb'),
        require => Package['check_mk-agent','check_mk-agent-logwatch'],
        notify  => Class['check_mk::agent::service'],
      }
    }

    'ssh': {
      if $generate_sshkey {
        check_mk::agent::generate_sshkey { "check_mk_key_${hostname}":
          keydir   => $keydir,
          authdir  => $authdir,
          authfile => $authfile,
          sshuser  => $sshuser,
          hostname => $hostname
        }
      }

      # make sure the xinetd method is not configured
      file { '/etc/xinetd.d/check_mk':
        ensure  => absent;
      }
    }

    default : {}
  }
}
