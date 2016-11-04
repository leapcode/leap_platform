class git::daemon::centos inherits git::daemon::base {

  package { 'git-daemon':
    ensure => installed,
    require => Package['git'],
    alias => 'git-daemon',
  }
  
  File['git-daemon_initscript'] {
    path => '/etc/init.d/git-daemon',
    require +> Package['git-daemon'],
  }

  File['git-daemon_config'] {
    path => '/etc/init.d/git-daemon',
    require +> Package['git-daemon'],
  }

}
