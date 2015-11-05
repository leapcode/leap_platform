# install ruby dev packages needed for building some gems
class site_config::ruby::dev inherits site_config::ruby {
  Class['::ruby'] {
    install_dev  => true
  }
  # building gems locally probably requires build-essential and gcc:
  include site_config::packages::build_essential
}
