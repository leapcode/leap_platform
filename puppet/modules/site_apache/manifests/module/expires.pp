class site_apache::module::expires ( $ensure = present )
{
  apache::module { 'expires': ensure => $ensure }
}
