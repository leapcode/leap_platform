class git::daemon::base inherits git::base {

  file { 'git-daemon_initscript':
    source => [ "puppet://$server/modules/site_git/init.d/${fqdn}/git-daemon",
                "puppet://$server/modules/site_git/init.d/${operatingsystem}/git-daemon",
                "puppet://$server/modules/site_git/init.d/git-daemon",
                "puppet://$server/modules/git/init.d/${operatingsystem}/git-daemon",
                "puppet://$server/modules/git/init.d/git-daemon" ],
    require => Package['git'],
    path => "/etc/init.d/git-daemon",
    owner => root, group => 0, mode => 0755;
  }
  
  file { 'git-daemon_config':
    source => [ "puppet://$server/modules/site_git/config/${fqdn}/git-daemon",
                "puppet://$server/modules/site_git/config/${operatingsystem}/git-daemon",
                "puppet://$server/modules/site_git/config/git-daemon",
                "puppet://$server/modules/git/config/${operatingsystem}/git-daemon",
                "puppet://$server/modules/git/config/git-daemon" ],
    require => Package['git'],
    path => "/etc/default/git-daemon",
    owner => root, group => 0, mode => 0644;
  }
  
  service { 'git-daemon':
    ensure => running,
    enable => true,
    hasstatus => true,
    require => [ File['git-daemon_initscript'], File['git-daemon_config'] ],
  }
}
