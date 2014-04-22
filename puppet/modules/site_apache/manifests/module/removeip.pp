class site_apache::module::removeip ( $ensure = present )
{
  package { 'libapache2-mod-removeip': ensure => $ensure }
  apache::module { 'removeip': ensure => $ensure }
}
