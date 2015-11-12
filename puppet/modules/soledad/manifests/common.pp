# install soledad-common, both needed both soledad-client and soledad-server
class soledad::common {

  include site_apt::preferences::twisted

  package { 'soledad-common':
    ensure  => latest;
  }

}
