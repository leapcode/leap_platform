# install mod_mpm_event (needed for jessie hosts)
class apache::module::mpm_event ( $ensure = present )
{

  apache::module { 'mpm_event': ensure => $ensure }

}
