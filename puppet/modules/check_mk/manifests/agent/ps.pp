define check_mk::agent::ps (
  # procname and levels have defaults in check_mk::ps
  $procname = undef,
  $levels = undef,
  # user is optional
  $user = undef
) {

  @@check_mk::ps { "${::fqdn}_${name}":
    desc     => $name,
    host     => $::fqdn,
    procname => $procname,
    user     => $user,
    levels   => $levels,
    tag      => 'check_mk_ps';
  }
}
