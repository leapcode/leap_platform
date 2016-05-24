# Arbitrary torrc snippet definition
define tor::daemon::snippet(
  $content = '',
  $ensure  = present ) {

  concat::fragment { "99.snippet.${name}":
    ensure  => $ensure,
    content => $content,
    owner   => 'debian-tor',
    group   => 'debian-tor',
    mode    => '0644',
    order   => 99,
    target  => $tor::daemon::config_file,
  }
}

