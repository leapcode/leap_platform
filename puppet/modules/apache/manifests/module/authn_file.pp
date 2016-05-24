# enable/disable authn_file module
class apache::module::authn_file ( $ensure = present )
{

  apache::module { 'authn_file': ensure => $ensure }
}
