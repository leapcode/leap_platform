define site_static::location($path, $format, $source) {

  $file_path = "/srv/static/${name}"

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
