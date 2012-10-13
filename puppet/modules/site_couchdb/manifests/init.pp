class site_couchdb {
  apt::sources_list { 'unstable.list':
    source => [ 'puppet:///modules/site_apt/unstable.list'],
  }


  class { 'couchdb':
    #bind => '0.0.0.0'
  }

}
