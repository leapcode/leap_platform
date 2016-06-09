define couchdb::ssl::deploy_cert ($cert, $key) {

  include couchdb::params

  file { 'couchdb_cert_directory':
    ensure  => 'directory',
    path    => $couchdb::params::cert_path,
    mode    => '0600',
    owner   => 'couchdb',
    group   => 'couchdb';
  }

  file { 'couchdb_cert':
    path    => "${couchdb::params::cert_path}/server_cert.pem",
    mode    => '0644',
    owner   => 'couchdb',
    group   => 'couchdb',
    content => $cert
  }

  file { 'couchdb_key':
    path    => "${couchdb::params::cert_path}/server_key.pem",
    mode    => '0600',
    owner   => 'couchdb',
    group   => 'couchdb',
    content => $key
  }
}
