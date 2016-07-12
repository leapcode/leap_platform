class apt::dot_d_directories {

  # watch .d directories and ensure they are present
  file {
    '/etc/apt/apt.conf.d':
      ensure   => directory,
      checksum => mtime,
      notify   => Exec['apt_updated'];
    '/etc/apt/sources.list.d':
      ensure   => directory,
      checksum => mtime,
      notify   => Exec['apt_updated'];
  }

}
