# This class simply makes sure a base tor is installed and configured
# It doesn't configure any specific hidden service functionality,
# instead that is configured in site_webapp::hidden_service and
# site_static::hidden_service.
#
# Those could be factored out to make them more generic.
class site_tor::hidden_service {
  tag 'leap_service'
  Class['site_config::default'] -> Class['site_tor::hidden_service']

  include site_config::default
  include site_tor
}
