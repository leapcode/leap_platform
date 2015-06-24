#
# currently, this is only used by static_site to get passenger v4.
#
# UPGRADE: this is not needed for jessie.
#
class site_apt::preferences::passenger {

  apt::preferences_snippet { 'passenger':
    package  => 'libapache2-mod-passenger',
    release  => "${::lsbdistcodename}-backports",
    priority => 999;
  }

}
