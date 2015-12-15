# this class is run by default, but can be excluded
# for testing purposes by calling "leap deploy" with
# the "--fast" parameter
class site_config::slow {
  tag 'leap_slow'
  class { 'site_apt::dist_upgrade': }
}
