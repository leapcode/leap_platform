class site_apache::module::headers ( $ensure = present )
{

  apache::module {'headers': ensure => $ensure }
}
