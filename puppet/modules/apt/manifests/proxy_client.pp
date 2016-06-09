class apt::proxy_client(
  $proxy = 'http://localhost',
  $port = '3142',
){

  apt_conf { '20proxy':
    content => template('apt/20proxy.erb'),
  }
}
