#
# Sets up stunnel and firewall configuration for
# a single stunnel client
#
# As a client, we accept connections on localhost,
# and connect to a remote $connect:$connect_port
#

define site_stunnel::client (
  $accept_port,
  $connect_port,
  $connect,
  $original_port,
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
    accept     => "127.0.0.1:${accept_port}",
    connect    => "${connect}:${connect_port}",
    client     => true,
    cafile     => $ca_path,
    key        => $key_path,
    cert       => $cert_path,
    verify     => $verify,
    pid        => "/var/run/stunnel4/${pid}.pid",
    rndfile    => $rndfile,
    debuglevel => $debuglevel,
    subscribe  => [
      Class['Site_config::X509::Key'],
      Class['Site_config::X509::Cert'],
      Class['Site_config::X509::Ca'] ];
  }

  site_shorewall::stunnel::client { $name:
    accept_port   => $accept_port,
    connect       => $connect,
    connect_port  => $connect_port,
    original_port => $original_port
  }

  include site_check_mk::agent::stunnel
}
