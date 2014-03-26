class site_config::ruby::dev inherits site_config::ruby {
  Class['::ruby'] {
    ruby_version => '1.9.3',
    install_dev  => true
  }
  # building gems locally probably requires build-essential and gcc:
  include site_config::packages::build_essential
}
