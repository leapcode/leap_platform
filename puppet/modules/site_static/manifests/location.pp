# configure static service for location
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
      cwd       => $file_path,
      command   => 'amber rebuild',
      user      => 'www-data',
      timeout   => 600,
      subscribe => Vcsrepo[$file_path]
    }
  }

  if ($format == 'rack') {
    # Run bundler if there is a Gemfile
    exec { 'bundler_update':
      cwd     => $file_path,
      command => '/bin/bash -c "/usr/bin/bundle check --path vendor/bundle || /usr/bin/bundle install --path vendor/bundle --without test development debug"',
      unless  => '/usr/bin/bundle check --path vendor/bundle',
      onlyif  => 'test -f Gemfile',
      user    => 'www-data',
      timeout => 600,
      require => [Class['bundler::install'], Class['site_config::ruby::dev']];
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
