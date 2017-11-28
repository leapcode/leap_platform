# Arbitrary torrc snippet definition
define tor::daemon::snippet(
  $content = '',
  $ensure  = present ) {

  concat::fragment { "99.snippet.${name}":
    ensure  => $ensure,
    content => $content,
    order   => 99,
    target  => $tor::daemon::config_file,
  }
}

