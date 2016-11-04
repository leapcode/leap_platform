# enable/disable auth_basic module
class apache::module::auth_basic ( $ensure = present )
{

  apache::module { 'auth_basic': ensure => $ensure }
}
