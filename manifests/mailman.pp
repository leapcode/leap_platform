#
# == Class: postfix::mailman
#
# Configures a basic smtp server, able to work for the mailman mailing-list
# manager.
#
# Example usage:
#
#   node "toto.example.com" {
#     include mailman
#     class { 'postfix::mailman': }
#   }
#
class postfix::mailman {
  class { 'postfix':
    smtp_listen => "0.0.0.0",
  }

  postfix::config {
    "mydestination":                        value => "";
    "virtual_alias_maps":                   value => "hash:/etc/postfix/virtual";
    "transport_maps":                       value => "hash:/etc/postfix/transport";
    "mailman_destination_recipient_limit":  value => "1", nonstandard => true;
  }

  postfix::hash { "/etc/postfix/virtual":
    ensure => present,
  }

  postfix::hash { "/etc/postfix/transport":
    ensure => present,
  }

}
