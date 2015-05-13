# install augeas packages from backports
class site_apt::preferences::augeas {

  # i could not get
  # site_config::remove_files::augeas::['rm_old_leap_mx_log_destination']
  # to remove a line matching a regex with the wheezy version of augeas-lenses
  # (0.10.0-1). Therefore we install it from backports

  apt::preferences_snippet { 'augeas':
    package  => 'augeas-lenses augeas-tools libaugeas0',
    release  => "${::lsbdistcodename}-backports",
    priority => 999;
  }

}
