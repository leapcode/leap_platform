define site_static::location($path, $format, $source) {

  $file_path = "/srv/static/${name}"
  $allowed_formats = ['amber','rack']

  if $format == undef {
    fail("static_site location `${path}` is missing `format` field.")
  }

  if ! member($allowed_formats, $format) {
    $formats_str = join($allowed_formats, ', ')
    fail("Unsupported static_site location format `${format}`. Supported formats include ${formats_str}.")
  }

  if ($format == 'amber') {
    exec {"amber_build_${name}":
      cwd     => $file_path,
      command => 'amber rebuild',
      user    => 'www-data',
      timeout => 600,
      subscribe => Vcsrepo[$file_path]
    }
  }

  vcsrepo { $file_path:
    ensure   => present,
    force    => true,
    revision => $source['revision'],
    provider => $source['type'],
    source   => $source['repo'],
    owner    => 'www-data',
    group    => 'www-data'
  }

}
