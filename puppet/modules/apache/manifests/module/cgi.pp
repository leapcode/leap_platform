# enable/disable cgi module
class apache::module::cgi ( $ensure = present )
{

  apache::module { 'cgi': ensure => $ensure }
}
