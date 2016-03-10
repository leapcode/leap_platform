# install soledad-common, both needed both soledad-client and soledad-server
class soledad::common {

  package { 'soledad-common':
    ensure  => latest;
  }

}
