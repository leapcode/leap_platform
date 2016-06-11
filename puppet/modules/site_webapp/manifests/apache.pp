# configure apache and passenger to serve the webapp
class site_webapp::apache {

  $web_api          = hiera('api')
  $api_domain       = $web_api['domain']
  $api_port         = $web_api['port']

  $web_domain       = hiera('domain')
  $domain_name      = $web_domain['name']

  $webapp           = hiera('webapp')
  $webapp_domain    = $webapp['domain']

  include site_apache::common
  include apache::module::headers
  include apache::module::alias
  include apache::module::expires
  include apache::module::removeip
  include site_webapp::common_vhost

  class { 'passenger': }

  apache::vhost::file {
    'api':
      content => template('site_apache/vhosts.d/api.conf.erb');
  }

}
