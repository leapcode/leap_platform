# enable/disable mpm_prefork module
class apache::module::mpm_prefork ( $ensure = present )
{

  apache::module { 'mpm_prefork': ensure => $ensure }
}
