# manage a basic tor installation
class tor (
  $ensure_version = 'installed'
){
  include tor::base
}
