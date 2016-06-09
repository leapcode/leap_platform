define couchdb::create_db (
  $host='127.0.0.1:5984',
  $admins="{\"names\": [], \"roles\": [] }",
  $members="{\"names\": [], \"roles\": [] }" )
{

  couchdb::query { "create_db_${name}":
    cmd    => 'PUT',
    host   => $host,
    path   => $name,
    unless => "/usr/bin/curl -s -f --netrc-file /etc/couchdb/couchdb.netrc ${host}/${name}"
  }

  couchdb::document { "${name}_security":
    db   => $name,
    id   => '_security',
    host => $host,
    data => "{ \"admins\": ${admins}, \"members\": ${members} }",
    require => Couchdb::Query["create_db_${name}"]
  }
}
