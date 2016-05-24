# enable/disable socache_shmcb module
class apache::module::socache_shmcb ( $ensure = present )
{

  apache::module { 'socache_shmcb': ensure => $ensure }
}
