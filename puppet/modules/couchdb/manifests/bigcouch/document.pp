define couchdb::bigcouch::document (
  $db,
  $id,
  $host = '127.0.0.1:5986',
  $data ='{}',
  $ensure ='content') {
  couchdb::document { $name:
    ensure => $ensure,
    host   => $host,
    db     => $db,
    id     => $id,
    data   => $data
  }
}
