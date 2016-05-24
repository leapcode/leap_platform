# enable/disable expires module
class apache::module::expires ( $ensure = present )
{
  apache::module { 'expires': ensure => $ensure }
}
