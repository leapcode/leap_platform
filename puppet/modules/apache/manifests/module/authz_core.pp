# install mod_authz_core (needed i.e. by the alias mod config)
class apache::module::authz_core ( $ensure = present )
{

  apache::module { 'authz_core': ensure => $ensure }

}
