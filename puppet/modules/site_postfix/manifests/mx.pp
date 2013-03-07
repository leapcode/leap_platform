class site_postfix::mx {

  $domain_hash = hiera ('domain')
  $domain = $domain_hash['full_suffix']

  # see https://leap.se/code/issues/1936 for contact email addr
  #$root_mail_recipient = ''
  $postfix_smtp_listen = 'all'

  postfix::config {
    # just en example
    'delay_warning_time':     value => '4h';
  }

  include ::postfix
}
