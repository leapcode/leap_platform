# setup soledad-client
# currently needed on webapp node to run the soledad-sync test
class soledad::client {

  tag 'leap_service'
  include soledad::common

  package {
    'soledad-client':
      ensure  => latest,
      require => [
        Class['site_apt::preferences::twisted'],
        Class['site_apt::leap_repo'] ];
    'python-u1db':
      ensure => latest;
  }

}
