class site_config::ruby::dev inherits site_config::ruby {
  Class['::ruby'] {
    ruby_version => '1.9.3',
    install_dev  => true
  }
}
