class site_postfix::mx {

  $domain_hash         = hiera ('domain')
  $domain              = $domain_hash['full_suffix']
  $mx_hash             = hiera('mx')

  $root_mail_recipient = $mx_hash['contact']
  $postfix_smtp_listen = 'all'

  postfix::config {
    # just en example
    'delay_warning_time':     value => '4h';
  }

  include ::postfix
}
