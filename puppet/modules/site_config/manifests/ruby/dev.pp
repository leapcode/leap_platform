# install ruby dev packages needed for building some gems
class site_config::ruby::dev {
  include site_config::ruby
  include ::ruby::devel

  # building gems locally probably requires build-essential and gcc:
  include site_config::packages::build_essential
}
