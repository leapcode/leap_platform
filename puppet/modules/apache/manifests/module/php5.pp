# enable/disable php5 module
class apache::module::php5 ( $ensure = present )
{

  apache::module { 'php5': ensure => $ensure }
}
