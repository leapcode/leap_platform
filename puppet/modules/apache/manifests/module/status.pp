# enable/disable status module
class apache::module::status ( $ensure = present )
{

  apache::module { 'status': ensure => $present }
}
