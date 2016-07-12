# set a default exec path
# the logoutput exec parameter defaults to "on_error" in puppet 3,
# but to "false" in puppet 2.7, so we need to set this globally here
Exec {
  logoutput => on_failure,
  path    => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin'
}

