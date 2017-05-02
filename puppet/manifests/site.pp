$services     = hiera('services', [])
$services_str = join($services, ', ')
notice("Services for ${fqdn}: ${services_str}")

node default {
  # set a default exec path
  # the logoutput exec parameter defaults to "on_error" in puppet 3,
  # but to "false" in puppet 2.7, so we need to set this globally here
  Exec {
    logoutput => on_failure,
    path      => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin'
  }

  Package <| provider == 'apt' |>  {
    install_options => ['--no-install-recommends'],
  }

  # In the default deployment case, we want to run an 'apt-get dist-upgrade'
  # to ensure the latest packages are installed. This is done by including the
  # class 'site_config::slow' here. However, you only changed a small bit of
  # the platform and want to skip this slow part of deployment, you can do that
  # by using 'leap deploy --fast' which will only apply those resources that are
  # tagged with 'leap_base' or 'leap_service'.
  # See https://leap.se/en/docs/platform/details/under-the-hood#tags
  include site_config::slow

  if member($services, 'openvpn') {
    include site_openvpn
  }

  if member($services, 'couchdb') {
    include site_couchdb
  }

  if member($services, 'webapp') {
    include site_webapp
  }

  if member($services, 'soledad') {
    include soledad::server
  }

  if member($services, 'monitor') {
    include site_nagios
  }

  if member($services, 'tor') {
    include site_tor::relay
  }

  if member($services, 'mx') {
    include site_mx
  }

  if member($services, 'static') {
    include site_static
  }

  if member($services, 'obfsproxy') {
    include site_obfsproxy
  }
}
