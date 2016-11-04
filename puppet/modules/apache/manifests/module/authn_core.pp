# enable/disable authn_core module
class apache::module::authn_core ( $ensure = present )
{

  apache::module { 'authn_core': ensure => $ensure }
}
