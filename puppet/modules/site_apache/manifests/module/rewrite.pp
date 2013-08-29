class site_apache::module::rewrite ( $ensure = present )
{

  apache::module { 'rewrite': ensure => $ensure }
}
