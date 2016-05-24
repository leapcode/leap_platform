# enable/disable authz_user module
class apache::module::authz_user ( $ensure = present )
{

  apache::module { 'authz_user': ensure => $ensure }
}
