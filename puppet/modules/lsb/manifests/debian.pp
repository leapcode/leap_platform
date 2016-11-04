class lsb::debian inherits lsb::base {
  Package['lsb']{
    name => 'lsb-release',
    require => undef,
  }
}
