# basic defaults for ssl support
class apache::ssl::base (
) {
  apache::config::include {
    'ssl_defaults.inc':
      content => template('apache/include.d/ssl_defaults.inc.erb');
  }

  if !$apache::no_default_site {
    apache::vhost::file{
      '0-default_ssl':
        content => template('apache/vhosts/0-default_ssl.conf.erb');
    }
  }
}
