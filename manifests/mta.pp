#
# == Class: postfix::mta
#
# This class configures a minimal MTA, listening on
# $postfix_smtp_listen (default to localhost) and delivering mail to
# $postfix_mydestination (default to $fqdn).
#
# A valid relay host is required ($postfix_relayhost) for outbound email.
#
# transport & virtual maps get configured and can be populated with
# postfix::transport and postfix::virtual
#
# Parameters:
# - *$postfix_relayhost*
# - *$postfix_mydestination*
# - every global variable which works for class "postfix" will work here.
#
# Requires:
# - Class["postfix"]
#
# Example usage:
#
#   node "toto.example.com" {
#
#     class { 'postfix':
#       smtp_listen => "0.0.0.0",
#     }
#
#     class { 'postfix::mta':
#       relayhost     => "mail.example.com",
#       mydestination => "\$myorigin, myapp.example.com",
#     }
#
#     postfix::transport { "myapp.example.com":
#       ensure => present,
#       destination => "local:",
#     }
#   }
#
class postfix::mta(
  $mydestination = '',
  $relayhost     = ''
) {

  #case $relayhost {
  #  "":   { fail("Required relayhost parameter is not defined.") }
  #}

  case $mydestination {
    "": { $postfix_mydestination = "\$myorigin" }
    default: { $postfix_mydestination = "$mydestination" }
  }

  postfix::config {
    "mydestination":                        value => $postfix_mydestination;
    "mynetworks":                           value => "127.0.0.0/8";
    "relayhost":                            value => $relayhost;
    "virtual_alias_maps":                   value => "hash:/etc/postfix/virtual";
    "transport_maps":                       value => "hash:/etc/postfix/transport";
  }

  postfix::hash { "/etc/postfix/virtual":
    ensure => present,
  }

  postfix::hash { "/etc/postfix/transport":
    ensure => present,
  }

}
