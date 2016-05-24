class check_mk::agent (
  $filestore    = undef,
  $host_tags    = undef,
  $ip_whitelist = undef,
  $port         = '6556',
  $server_dir   = '/usr/bin',
  $keydir       = '/omd/sites/monitoring',
  $authdir      = '/omd/sites/monitoring',
  $authfile     = undef,
  $use_cache    = false,
  $user         = 'root',
  $version      = undef,
  $workspace    = '/root/check_mk',
  $agent_package_name           = 'check_mk-agent',
  $agent_logwatch_package_name  = 'check_mk-agent-logwatch',
  $method                       = 'xinetd',
  $generate_sshkey              = false,
  $sshuser                      = undef,
  $use_ssh_tag                  = 'ssh',
  $hostname                     = $::fqdn,
  $register_agent               = true
) {

  case $method {
    'xinetd': {
      $tags = $host_tags
      include check_mk::agent::service
    }
    'ssh': {
      if ( $host_tags == undef ) or ( $host_tags == '' ) {
        $tags = $use_ssh_tag
      } else {
        $tags = "${host_tags}|${use_ssh_tag}"
      }
    }
    default: {}
  }

  class { 'check_mk::agent::install':
    version                     => $version,
    filestore                   => $filestore,
    workspace                   => $workspace,
    agent_package_name          => $agent_package_name,
    agent_logwatch_package_name => $agent_logwatch_package_name,
    method                      => $method
  }

  class { 'check_mk::agent::config':
    ip_whitelist    => $ip_whitelist,
    port            => $port,
    server_dir      => $server_dir,
    keydir          => $keydir,
    authdir         => $authdir,
    authfile        => $authfile,
    use_cache       => $use_cache,
    user            => $user,
    method          => $method,
    generate_sshkey => $generate_sshkey,
    sshuser         => $sshuser,
    hostname        => $hostname,
    require         => Class['check_mk::agent::install'],
  }

  if ( $register_agent ) {
    class { 'check_mk::agent::register':
      host_tags => $tags,
      hostname  => $hostname,
    }
  }
}
