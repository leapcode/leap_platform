class site_mx::couchdb {

  $stunnel = hiera('stunnel')
  $couch_client            = $stunnel['couch_client']
  $couch_client_connect    = $couch_client['connect']

  include x509::variables
  $x509                    = hiera('x509')
  $key                     = $x509['key']
  $cert                    = $x509['cert']
  $ca                      = $x509['ca_cert']
  $cert_name               = 'leap_couchdb'
  $ca_name                 = 'leap_ca'
  $ca_path                 = "${x509::variables::local_CAs}/${ca_name}.crt"
  $cert_path               = "${x509::variables::certs}/${cert_name}.crt"
  $key_path                = "${x509::variables::keys}/${cert_name}.key"

  site_stunnel::setup {'mx_couchdb':
    cert_name => $cert_name,
    key       => $key,
    cert      => $cert,
    ca_name   => $ca_name,
    ca        => $ca
  }

  $couchdb_stunnel_client_defaults = {
    'connect_port' => $couch_client_connect,
    'client'     => true,
    'cafile'     => $ca_path,
    'key'        => $key_path,
    'cert'       => $cert_path,
  }

  create_resources(site_stunnel::clients, $couch_client, $couchdb_stunnel_client_defaults)
}
