class site_apache::common {

  include site_apache::module::rewrite

  class { '::apache': no_default_site => true, ssl => true }

  include site_apache::common::tls
}
