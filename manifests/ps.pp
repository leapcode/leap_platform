define check_mk::ps (
  $target,
  $host,
  $desc,
  $procname = "/usr/sbin/${desc}",
  $levels = '1, 1, 1, 1',
  $user = undef
) {
  # This class is called on check-mk agent machines in order to create
  # checks using the built-in ps check type. They create stored configs
  # and then the check_mk::server::collect_ps class on the server
  # generates the config file to set them up

  # lines in the ps.mk config file look like
  # ( "foo.example.com", "ps", "NAME", ( "/usr/sbin/foo", 1, 1, 1, 1 ) )
  # or with a user
  # ( "foo.example.com", "ps", "NAME", ( "/usr/sbin/foo", "user", 1, 1, 1, 1 ) )
  if $user {
    $check = "  ( \"${host}\", \"ps\", \"${desc}\", ( \"${procname}\", ${user}, ${levels} ) ),\n"
  } else {
    $check = "  ( \"${host}\", \"ps\", \"${desc}\", ( \"${procname}\", ${levels} ) ),\n"
  }

  # FIXME: we could be smarter about this and consolidate host checks
  # that have identical settings and that would make the config file
  # make more sense for humans. but for now we'll just do separate
  # lines (which may result in a very large file, but check-mk is fine)
  concat::fragment { "check_mk_ps-${host}_${desc}":
    target  => $target,
    content => $check,
    order   => 20
  }
}

