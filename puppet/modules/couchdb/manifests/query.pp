define couchdb::query (
  $cmd, $path,
  $netrc='/etc/couchdb/couchdb.netrc',
  $host='127.0.0.1:5984',
  $data = '{}',
  $unless = undef) {

  exec { "/usr/bin/curl -s --netrc-file ${netrc} -X ${cmd} ${host}/${path} --data \'${data}\'":
    require => [ Package['curl'], Exec['wait_for_couchdb'] ],
    unless  => $unless
  }
}
