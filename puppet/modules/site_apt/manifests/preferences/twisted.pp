# Pin twisted to jessie-backports in order to
# use 16.2.0 for i.e. soledad
class site_apt::preferences::twisted {

  apt::preferences_snippet { 'twisted':
    package  => 'python-twisted*',
    release  => "${::lsbdistcodename}-backports",
    priority => 999;
  }

}
