define site_openvpn::server_config($port, $proto) {
  $openvpn_configname=$name
  notice("Creating OpenVPN $openvpn_configname:
    Port: $port, Protocol: $proto")

  file {
    "/etc/openvpn/${name}":
      ensure  => directory,
      require => Package['openvpn'];
  }

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
        value   => '/etc/openvpn/ca.crt',
        #require => Exec["initca $openvpn_configname"],
        server  => $openvpn_configname;
    "cert $openvpn_configname":
        key     => 'cert',
        value   => "/etc/openvpn/$openvpn_configname/server.crt",
        #require => Exec["generate server cert $openvpn_configname"],
        server  => $openvpn_configname;
    "key $openvpn_configname":
        key     => "key",
        value   => "/etc/openvpn/$openvpn_configname/server.key",
        #require => Exec["generate server cert $openvpn_configname"],
        server  => "$openvpn_configname";
    "dh $openvpn_configname":
        key     => "dh",
        value   => "/etc/openvpn/dh1024.pem",
        #require => Exec["generate dh param $openvpn_configname"],
        server  => "$openvpn_configname";
    "dev $openvpn_configname":
        key    => "dev",
        value  => "tun",
        server => "$openvpn_configname";
    "mode $openvpn_configname":            
       key    => 'mode',      
       value  => 'server',    
       server => $openvpn_configname;       
    "script-security $openvpn_configname":
        key    => "script-security",
        value  => "3",
        server => "$openvpn_configname";
    "daemon $openvpn_configname":
        key    => "daemon",
        server => "$openvpn_configname";
    "keepalive $openvpn_configname":
        key    => "keepalive",
        value  => "10 60",
        server => "$openvpn_configname";
    "ping-timer-rem $openvpn_configname":
        key    => "ping-timer-rem",
        server => "$openvpn_configname";
    "persist-tun $openvpn_configname":
        key    => "persist-tun",
        server => "$openvpn_configname";
    "persist-key $openvpn_configname":
        key    => "persist-key",
        server => "$openvpn_configname";
    "proto $openvpn_configname":
        key    => "proto",
        value  => "$proto",
        server => "$openvpn_configname";
    "cipher $openvpn_configname":
        key    => "cipher",
        value  => "BF-CBC",
        server => "$openvpn_configname";
    "local $openvpn_configname":
        key    => "local",
        value  => $ipaddress,
        server => "$openvpn_configname";
    "tls-server $openvpn_configname":
        key    => "tls-server",
        server => "$openvpn_configname";
    #"server $openvpn_configname":
    #    key    => "server",
    #    value  => "$server",
    #    server => "$openvpn_configname";
    "lport $openvpn_configname":
        key    => "lport",
        value  => "$port",
        server => "$openvpn_configname";
    "management $openvpn_configname":
        key    => "management",
        value  => "/var/run/openvpn-$openvpn_configname.sock unix",
        server => "$openvpn_configname";
    "comp-lzo $openvpn_configname":
        key    => "comp-lzo",
        server => "$openvpn_configname";
    "topology $openvpn_configname":
        key    => "topology",
        value  => "subnet",
        server => "$openvpn_configname";
    #"client-to-client $openvpn_configname":
    #    key    => "client-to-client",
    #    server => "$openvpn_configname";
  }

}
