# enable/disable mime module
class apache::module::mime ( $ensure = present )
{

  apache::module { 'mime': ensure => $ensure }
}
