class site_postfix::satellite {

  $root_mail_recipient = hiera ('contacts')
  $mail                = hiera ('mail')
  $relayhost           = $mail['smarthost']

  class { '::postfix::satellite':
    relayhost           => $relayhost,
    root_mail_recipient => $root_mail_recipient
  }
}
