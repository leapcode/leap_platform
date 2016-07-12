# enable/disable dir module
class apache::module::dir ( $ensure = present )
{

  apache::module { 'dir': ensure => $ensure }
}
