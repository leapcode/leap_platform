# install mod_alias
class apache::module::alias ( $ensure = present )
{

  apache::module { 'alias': ensure => $ensure }

  # from 2.4, /etc/apache2/mods-enabled/alias.conf contains the "Require"
  # directive which needs "authz_core" mod enabled

  if ( guess_apache_version() == '2.4') {
    class { 'authz_core': ensure => $ensure }
  }

}
