# enable/disable headers module
class apache::module::headers ( $ensure = present )
{

  apache::module { 'headers': ensure => $ensure }
}
