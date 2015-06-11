class site_webapp::apache {

  $web_api          = hiera('api')
  $api_domain       = $web_api['domain']
  $api_port         = $web_api['port']

  $web_domain       = hiera('domain')
  $domain_name      = $web_domain['name']

  $webapp           = hiera('webapp')
  $webapp_domain    = $webapp['domain']

  include site_apache::common
  include site_apache::module::headers
  include site_apache::module::alias
  include site_apache::module::expires
  include site_apache::module::removeip

  class { 'passenger': use_munin => false }

  apache::vhost::file {
    'api':
      content => template('site_apache/vhosts.d/api.conf.erb')
  }

}
