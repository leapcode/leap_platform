#
# example hiera yaml:
#
#   stunnel:
#     servers:
#       couch_server:
#         accept_port: 15984
#         connect_port: 5984
#

define site_stunnel::servers (
  $accept_port,
  $connect_port,
  $verify     = '2',
  $pid        = $name,
  $rndfile    = '/var/lib/stunnel4/.rnd',
  $debuglevel = '4' ) {

  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::ca
  include x509::variables
  $ca_path   = "${x509::variables::local_CAs}/${site_config::params::ca_name}.crt"
  $cert_path = "${x509::variables::certs}/${site_config::params::cert_name}.crt"
  $key_path  = "${x509::variables::keys}/${site_config::params::cert_name}.key"

  stunnel::service { $name:
    accept     => $accept_port,
    connect    => "127.0.0.1:${connect_port}",
    client     => false,
    cafile     => $ca_path,
    key        => $key_path,
    cert       => $cert_path,
    verify     => $verify,
    pid        => "/var/run/stunnel4/${pid}.pid",
    rndfile    => '/var/lib/stunnel4/.rnd',
    debuglevel => $debuglevel,
    require    => [
      Class['Site_config::X509::Key'],
      Class['Site_config::X509::Cert'],
      Class['Site_config::X509::Ca'] ];
  }

  # allow incoming connections on $accept_port
  site_shorewall::stunnel::server { $name:
    port  => $accept_port
  }

  include site_check_mk::agent::stunnel
}
