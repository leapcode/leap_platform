class stunnel::linux inherits stunnel::base {

  package { 'stunnel':
    ensure => $stunnel::ensure_version
  }
}
