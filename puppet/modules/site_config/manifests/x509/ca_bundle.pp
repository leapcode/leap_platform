class site_config::x509::ca_bundle {

  # CA bundle -- we want to have the possibility of allowing multiple CAs.
  # For now, the reason is to transition to using client CA. In the future,
  # we will want to be able to smoothly phase out one CA and phase in another.
  # I tried "--capath" for this, but it did not work.

  include ::site_config::params

  $x509      = hiera('x509')
  $ca        = $x509['ca_cert']
  $client_ca = $x509['client_ca_cert']

  x509::ca { $site_config::params::ca_bundle_name:
    content => "${ca}${client_ca}"
  }
}
