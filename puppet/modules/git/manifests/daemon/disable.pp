class git::daemon::disable inherits git::daemon::base {

  if defined(Package['git-daemon']) {
    Package['git-daemon'] {
      ensure => absent,
    }
  }

  File['git-daemon_initscript'] { 
    ensure => absent,
  }
  
  File['git-daemon_config'] {
    ensure => absent,
  }
  
  Service['git-daemon'] {
    ensure => stopped,
    enable => false,
    require => undef,
    before => File['git-daemon_initscript'],
  }

  if $use_shorewall {
    include shorewall::rules::gitdaemon::absent
  }

  if $use_nagios {
    nagios::service { "git-daemon": check_command => "check_git!${fqdn}", ensure => absent; }
  }
}


