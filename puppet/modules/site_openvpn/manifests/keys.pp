class site_openvpn::keys {

  x509::key {
    'leap_openvpn':
      content => $site_openvpn::x509_config['key'],
      notify  => Service[openvpn];
  }

  x509::cert {
    'leap_openvpn':
      content => $site_openvpn::x509_config['cert'],
      notify  => Service[openvpn];
  }

  x509::ca {
    'leap_ca':
      content => $site_openvpn::x509_config['ca_cert'],
      notify  => Service[openvpn];
  }

  file { '/etc/openvpn/keys/dh.pem':
    content => $site_openvpn::x509_config['dh'],
    mode    => '0644',
  }

  #
  # CA bundle -- we want to have the possibility of allowing multiple CAs.
  # For now, the reason is to transition to using client CA. In the future,
  # we will want to be able to smoothly phase out one CA and phase in another.
  # I tried "--capath" for this, but it did not work.
  #

  concat {
    '/etc/openvpn/ca_bundle.pem':
      owner  => root,
      group  => root,
      mode   => 644,
      warn   => true,
      notify => Service['openvpn'];
  }

  concat::fragment {
    'client_ca_cert':
      content => $site_openvpn::x509_config['client_ca_cert'],
      target  => '/etc/openvpn/ca_bundle.pem';
    'ca_cert':
      content => $site_openvpn::x509_config['ca_cert'],
      target  => '/etc/openvpn/ca_bundle.pem';
  }

}
