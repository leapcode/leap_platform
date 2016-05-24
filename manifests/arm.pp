# manage tor-arm
class tor::arm (
  $ensure_version = 'installed'
){
  include ::tor
  package{'tor-arm':
    ensure => $ensure_version,
  }
}
