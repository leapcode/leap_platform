node 'cougar.leap.se' {
  openvpn::server {
    'cougar.leap.se':
        country      => 'TR',
        province     => 'Ankara',
        city         => 'Ankara',
        organization => 'leap.se',
        email        => 'sysdev@leap.se';
}

}

node 'default' {
  notify {'Please specify a host in site.pp!':}
}
