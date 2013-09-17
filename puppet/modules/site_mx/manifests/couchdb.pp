class site_mx::couchdb {

  $stunnel = hiera('stunnel')
  $couch_client            = $stunnel['couch_client']
  $couch_client_connect    = $couch_client['connect']

  include x509::variables
  $ca_path                 = "${x509::variables::local_CAs}/${site_config::params::ca_name}.crt"
  $cert_path               = "${x509::variables::certs}/${site_config::params::cert_name}.crt"
  $key_path                = "${x509::variables::keys}/${site_config::params::cert_name}.key"

  include site_stunnel

  $couchdb_stunnel_client_defaults = {
    'connect_port' => $couch_client_connect,
    'client'     => true,
    'cafile'     => $ca_path,
    'key'        => $key_path,
    'cert'       => $cert_path,
  }

  create_resources(site_stunnel::clients, $couch_client, $couchdb_stunnel_client_defaults)
}
