# enable/disable rewrite module
class apache::module::rewrite ( $ensure = present )
{

  apache::module { 'rewrite': ensure => $ensure }
}
