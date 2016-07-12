class git::daemon::vhosts inherits git::daemon {

  File['git-daemon_config']{
    source => [ "puppet://$server/modules/site_git/config/${fqdn}/git-daemon.vhosts",
                "puppet://$server/modules/site_git/config/${operatingsystem}/git-daemon.vhosts",
                "puppet://$server/modules/site_git/config/git-daemon.vhosts",
                "puppet://$server/modules/git/config/${operatingsystem}/git-daemon.vhosts",
                "puppet://$server/modules/git/config/git-daemon.vhosts" ],
  }
}
