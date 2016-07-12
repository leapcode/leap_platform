define couchdb::mirror_db (
  $host='127.0.0.1:5984',
  $from='',
  $to='',
  $user='replication',
  $role='replication'
  )
{
  $source = "${from}/${name}"
  if $to == '' { $target = $name }
  else { $target = "${to}/${name}" }

  couchdb::document { "${name}_replication":
    db      => "_replicator",
    id      => "${name}_replication",
    netrc   => "/etc/couchdb/couchdb-${user}.netrc",
    host    => $host,
    data    => "{ \"source\": \"${source}\", \"target\": \"${target}\", \"continuous\": true, \"user_ctx\": { \"name\": \"${user}\", \"roles\": [\"${role}\"] }, \"owner\": \"${user}\" }",
    require => Couchdb::Query["create_db_${name}"]
  }
}
