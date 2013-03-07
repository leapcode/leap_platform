class site_mx {
  tag 'leap_service'

  include site_postfix::mx
  include site_shorewall::mx
  include site_shorewall::service::smtp
}
