class site_openvpn {

  $openvpn_server=$::fqdn

  openvpn::server {
    $openvpn_server:
        country      => hiera("country"),
        province     => hiera("province"),
        city         => hiera("city"),
        organization => hiera("organization"),
        email        => hiera("email");
  }

# configure server


  openvpn::option {
    "dev $openvpn_server":
        key    => "dev",
        value  => "tun0",
        server => "$openvpn_server";
    "script-security $openvpn_server":
        key    => "script-security",
        value  => "3",
        server => "$openvpn_server";
    "daemon $openvpn_server":
        key    => "daemon",
        server => "$openvpn_server";
    "keepalive $openvpn_server":
        key    => "keepalive",
        value  => "10 60",
        server => "$openvpn_server";
    "ping-timer-rem $openvpn_server":
        key    => "ping-timer-rem",
        server => "$openvpn_server";
    "persist-tun $openvpn_server":
        key    => "persist-tun",
        server => "$openvpn_server";
    "persist-key $openvpn_server":
        key    => "persist-key",
        server => "$openvpn_server";
    "proto $openvpn_server":
        key    => "proto",
        value  => "tcp-server",
        server => "$openvpn_server";
    "cipher $openvpn_server":
        key    => "cipher",
        value  => "BF-CBC",
        server => "$openvpn_server";
    "local $openvpn_server":
        key    => "local",
        value  => $ipaddress,
        server => "$openvpn_server";
    "tls-server $openvpn_server":
        key    => "tls-server",
        server => "$openvpn_server";
    "server $openvpn_server":
        key    => "server",
        value  => "10.10.10.0 255.255.255.0",
        server => "$openvpn_server";
    "lport $openvpn_server":
        key    => "lport",
        value  => "1194",
        server => "$openvpn_server";
    "management $openvpn_server":
        key    => "management",
        value  => "/var/run/openvpn-$openvpn_server.sock unix",
        server => "$openvpn_server";
    "comp-lzo $openvpn_server":
        key    => "comp-lzo",
        server => "$openvpn_server";
    "topology $openvpn_server":
        key    => "topology",
        value  => "subnet",
        server => "$openvpn_server";
    "client-to-client $openvpn_server":
        key    => "client-to-client",
        server => "$openvpn_server";
  }

}
