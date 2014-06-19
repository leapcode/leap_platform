class site_couchdb::stunnel {

  $stunnel              = hiera('stunnel')
  $couchdb_config       = hiera('couch')
  $couchdb_bigcouch     = $couchdb_config['mode'] == "multimaster"

  $couch_server         = $stunnel['couch_server']
  $couch_server_accept  = $couch_server['accept']
  $couch_server_connect = $couch_server['connect']

  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::ca

  if $couchdb_bigcouch {
    include site_couchdb::bigcouch::stunnel
  }

  include x509::variables
  $ca_path   = "${x509::variables::local_CAs}/${site_config::params::ca_name}.crt"
  $cert_path = "${x509::variables::certs}/${site_config::params::cert_name}.crt"
  $key_path  = "${x509::variables::keys}/${site_config::params::cert_name}.key"

  # setup a stunnel server for the webapp to connect to couchdb
  stunnel::service { 'couch_server':
    accept     => $couch_server_accept,
    connect    => $couch_server_connect,
    client     => false,
    cafile     => $ca_path,
    key        => $key_path,
    cert       => $cert_path,
    verify     => '2',
    pid        => '/var/run/stunnel4/couchserver.pid',
    rndfile    => '/var/lib/stunnel4/.rnd',
    debuglevel => '4',
    require    => [
      Class['Site_config::X509::Key'],
      Class['Site_config::X509::Cert'],
      Class['Site_config::X509::Ca'] ];
  }

  include site_check_mk::agent::stunnel
}
