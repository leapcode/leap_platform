class site_apache::common::tls {
  # class to setup common SSL configurations

  apache::config::include{ 'ssl_common.inc': }

}
