define site_openvpn::server_config($port, $protocol) {
  $openvpn_configname=$name
  notice("Creating OpenVPN $openvpn_configname:  
    Port: $port, Protocol: $protocol")

  $openvpn_server=$::fqdn
  # we don't need a ca generated
  #openvpn::server {
  #  $openvpn_configname:
  #      country      => hiera("country"),
  #      province     => hiera("province"),
  #      city         => hiera("city"),
  #      organization => hiera("organization"),
  #      email        => hiera("email");
  #}

  # configure server
  # all config options need to be "hieraized"

  openvpn::option {
    "dev $openvpn_configname":
        key    => "dev",
        value  => "tun",
        server => "$openvpn_server";
    "script-security $openvpn_configname":
        key    => "script-security",
        value  => "3",
        server => "$openvpn_server";
    "daemon $openvpn_configname":
        key    => "daemon",
        server => "$openvpn_server";
    "keepalive $openvpn_configname":
        key    => "keepalive",
        value  => "10 60",
        server => "$openvpn_server";
    "ping-timer-rem $openvpn_configname":
        key    => "ping-timer-rem",
        server => "$openvpn_server";
    "persist-tun $openvpn_configname":
        key    => "persist-tun",
        server => "$openvpn_server";
    "persist-key $openvpn_configname":
        key    => "persist-key",
        server => "$openvpn_server";
    "proto $openvpn_configname":
        key    => "proto",
        value  => "$proto",
        server => "$openvpn_server";
    "cipher $openvpn_configname":
        key    => "cipher",
        value  => "BF-CBC",
        server => "$openvpn_server";
    "local $openvpn_configname":
        key    => "local",
        value  => $ipaddress,
        server => "$openvpn_server";
    "tls-server $openvpn_configname":
        key    => "tls-server",
        server => "$openvpn_server";
    "server $openvpn_configname":
        key    => "server",
        value  => "$server",
        server => "$openvpn_server";
    "lport $openvpn_configname":
        key    => "lport",
        value  => "$port",
        server => "$openvpn_server";
    "management $openvpn_configname":
        key    => "management",
        value  => "/var/run/openvpn-$openvpn_configname.sock unix",
        server => "$openvpn_server";
    "comp-lzo $openvpn_configname":
        key    => "comp-lzo",
        server => "$openvpn_server";
    "topology $openvpn_configname":
        key    => "topology",
        value  => "subnet",
        server => "$openvpn_server";
    "client-to-client $openvpn_configname":
        key    => "client-to-client",
        server => "$openvpn_server";
  }

}
