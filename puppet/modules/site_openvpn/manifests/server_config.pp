define site_openvpn::server_config($port, $proto) {
  $openvpn_configname = $name

  #notice("Creating OpenVPN $openvpn_configname:
  #  Port: $port, Protocol: $proto")

  concat {
    "/etc/openvpn/$openvpn_configname.conf":
        owner   => root,
        group   => root,
        mode    => 644,
        warn    => true,
        require => File['/etc/openvpn'],
        notify  => Service['openvpn'];
  }

  openvpn::option {
    "ca $openvpn_configname":
        key     => 'ca',
        value   => '/etc/openvpn/keys/ca.crt',
        server  => $openvpn_configname;
    "cert $openvpn_configname":
        key     => 'cert',
        value   => '/etc/openvpn/keys/server.crt',
        server  => $openvpn_configname;
    "key $openvpn_configname":
        key     => 'key',
        value   => '/etc/openvpn/keys/server.key',
        server  => $openvpn_configname;
    "dh $openvpn_configname":
        key     => 'dh',
        value   => '/etc/openvpn/keys/dh1024.pem',
        server  => $openvpn_configname;

    "dev $openvpn_configname":
        key    => 'dev',
        value  => 'tun',
        server => $openvpn_configname;
    "duplicate-cn $openvpn_configname":
        key    => 'duplicate-cn',
        server => $openvpn_configname;
    "keepalive $openvpn_configname":
        key    => 'keepalive',
        value  => '5 20',
        server => $openvpn_configname;
    "local $openvpn_configname":
        key    => 'local',
        value  => $::ipaddress,
        server => $openvpn_configname;
    "mute $openvpn_configname":
        key    => 'mute',
        value  => '5',
        server => $openvpn_configname;
    "mute-replay-warnings $openvpn_configname":
        key    => 'mute-replay-warnings',
        server => $openvpn_configname;
    "management $openvpn_configname":
        key    => 'management',
        value  => '127.0.0.1 1000',
        server => $openvpn_configname;
    "proto $openvpn_configname":
        key    => 'proto',
        value  => $proto,
        server => $openvpn_configname;
    "push $openvpn_configname":
        key    => 'push',
        value  => "\"redirect-gateway def1\"",
        server => $openvpn_configname;
    "script-security $openvpn_configname":
        key    => 'script-security',
        value  => '2',
        server => $openvpn_configname;
    "server $openvpn_configname":
        key    => 'server',
        value  => "10.42.0.0 255.255.248.0",
        server => $openvpn_configname;
    "status $openvpn_configname":
        key    => 'status',
        value  => '/var/run/openvpn-status 10',
        server => $openvpn_configname;
    "status-version $openvpn_configname":
        key    => 'status-version',
        value  => '3',
        server => $openvpn_configname;
    "topology $openvpn_configname":
        key    => 'topology',
        value  => 'subnet',
        server => $openvpn_configname;
    "up $openvpn_configname":
        key    => 'up',
        value  => '/etc/openvpn/server-up.sh',
        server => $openvpn_configname;
    "verb $openvpn_configname":
        key    => 'verb',
        value  => '3',
        server => $openvpn_configname;
  }
}
