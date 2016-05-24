class lsb::centos inherits lsb::base {
  Package['lsb']{
    name => 'redhat-lsb',
  }
}
