# remove possible leftovers after upgrading from wheezy to jessie
class site_config::remove::jessie {

  tidy {
    '/etc/apt/preferences.d/rsyslog_anon_depends':
      notify => Exec['refresh_apt'];
  }

}
