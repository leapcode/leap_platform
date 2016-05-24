define couchdb::update (
  $db,
  $id,
  $data,
  $host='127.0.0.1:5984',
  $unless=undef) {

  exec { "couch-doc-update --host ${host} --db ${db} --id ${id} --data \'${data}\'":
    require => Exec['wait_for_couchdb'],
    unless  => $unless
  }
}
