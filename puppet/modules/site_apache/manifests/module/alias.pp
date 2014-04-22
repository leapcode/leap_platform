class site_apache::module::alias ( $ensure = present )
{

  apache::module { 'alias': ensure => $ensure }
}
