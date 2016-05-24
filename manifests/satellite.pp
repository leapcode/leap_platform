#
# == Class: postfix::satellite
#
# This class configures all local email (cron, mdadm, etc) to be forwarded
# to $root_mail_recipient, using $postfix_relayhost as a relay.
#
# $valid_fqdn can be set to override $fqdn in the case where the FQDN is
# not recognized as valid by the destination server.
#
# Parameters:
# - *valid_fqdn*
# - every global variable which works for class "postfix" will work here.
#
# Example usage:
#
#   node "toto.local.lan" {
#     class { 'postfix::satellite':
#       relayhost           => "mail.example.com"
#       valid_fqdn          => "toto.example.com"
#       root_mail_recipient => "the.sysadmin@example.com"
#     }
#   }
#
class postfix::satellite(
  $relayhost           = '',
  $valid_fqdn          = $::fqdn,
  $root_mail_recipient = ''
) {

  # If $valid_fqdn is provided, use it to override $fqdn
  if $valid_fqdn != $::fdqn {
    $fqdn = $valid_fqdn
  }

  class { 'postfix':
    root_mail_recipient => $root_mail_recipient,
    myorigin            => $valid_fqdn,
    mailname            => $valid_fqdn
  }

  class { 'postfix::mta':
    relayhost => $relayhost,
  }

  postfix::virtual {"@${valid_fqdn}":
    ensure      => present,
    destination => "root",
  }
}
