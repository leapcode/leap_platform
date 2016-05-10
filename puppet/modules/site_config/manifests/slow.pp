# this class is run by default, but can be excluded
# for testing purposes by calling "leap deploy" with
# the "--fast" parameter
class site_config::slow {
  tag 'leap_slow'

  include site_config::default
  include apt::update
  class { 'site_apt::dist_upgrade': }
}
