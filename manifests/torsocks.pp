# manage torsocks
class tor::torsocks (
  $ensure_version = 'installed'
){
  include ::tor
  package{'torsocks':
    ensure => $ensure_version,
  }
}
