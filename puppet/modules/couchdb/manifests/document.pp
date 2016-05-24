# Usage:
# couchdb::document { id:
#   db => "database",
#   data => "content",
#   ensure => {absent,present,*content*}
# }
#
define couchdb::document(
  $db,
  $id,
  $host   = '127.0.0.1:5984',
  $data   = '{}',
  $netrc  = '/etc/couchdb/couchdb.netrc',
  $ensure = 'content') {

  $url = "${host}/${db}/${id}"

  case $ensure {
    default: { err ( "unknown ensure value '${ensure}'" ) }
    content: {
      exec { "couch-doc-update --netrc-file ${netrc} --host ${host} --db ${db} --id ${id} --data \'${data}\'":
        require => Exec['wait_for_couchdb'],
        unless  => "couch-doc-diff $url '$data'"
      }
    }

    present: {
      couchdb::query { "create_${db}_${id}":
        cmd    => 'PUT',
        host   => $host,
        path   => "${db}/${id}",
        require => Exec['wait_for_couchdb'],
        unless => "/usr/bin/curl -s -f --netrc-file ${netrc} ${url}"
      }
    }

    absent: {
      couchdb::query { "destroy_${db}_${id}":
        cmd    => 'DELETE',
        host   => $host,
        path   => "${db}/${id}",
        require => Exec['wait_for_couchdb'],
        unless => "/usr/bin/curl -s -f --netrc-file ${netrc} ${url}"
      }
    }
  }
}
