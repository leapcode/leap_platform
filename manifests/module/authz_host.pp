# enable/disable authz_host module
class apache::module::authz_host ( $ensure = present )
{

  apache::module { 'authz_host': ensure => $ensure }
}
