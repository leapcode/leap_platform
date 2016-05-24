class check_mk::htpasswd (
  $password,
  $username = 'omdadmin',
  $path = '/opt/omd/sites/monitoring/etc/htpasswd' ) {

  apache::htpasswd_user { $username:
    ensure   => present,
    username => $username,
    password => $password,
    path     => $path
  }
}
