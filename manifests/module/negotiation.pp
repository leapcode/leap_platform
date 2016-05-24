# enable/disable negotiation module
class apache::module::negotiation ( $ensure = present )
{

  apache::module { 'negotiation': ensure => $ensure }
}
