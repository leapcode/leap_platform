class site_static {
  tag 'leap_service'
  $static        = hiera('static')
  $domains       = $static['domains']
  $formats       = $static['formats']

  if (member($formats, 'amber')) {
    include site_config::ruby::dev
    rubygems::gem{'amber': }
  }

  create_resources(site_static::domain, $domains)
}