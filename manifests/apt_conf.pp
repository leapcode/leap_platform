define apt::apt_conf(
  $ensure = 'present',
  $source = '',
  $content = undef,
  $refresh_apt = true )
{

  if $source == '' and $content == undef {
    fail("One of \$source or \$content must be specified for apt_conf ${name}")
  }

  if $source != '' and $content != undef {
    fail("Only one of \$source or \$content must specified for apt_conf ${name}")
  }

  include apt::dot_d_directories

  # One would expect the 'file' resource on sources.list.d to trigger an
  # apt-get update when files are added or modified in the directory, but it
  # apparently doesn't.
  file { "/etc/apt/apt.conf.d/${name}":
    ensure => $ensure,
    owner  => root,
    group  => 0,
    mode   => '0644',
  }

  if $source {
    File["/etc/apt/apt.conf.d/${name}"] {
      source => $source,
    }
  }
  else {
    File["/etc/apt/apt.conf.d/${name}"] {
      content => $content,
    }
  }

  if $refresh_apt {
    File["/etc/apt/apt.conf.d/${name}"] {
      notify => Exec['apt_updated'],
    }
  }

}
