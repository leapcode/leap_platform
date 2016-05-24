/*
== Definition: postfix::tlspolicy_snippet

Adds a TLS policy snippets to /etc/postfix/tls_policy.
See the postfix::tlspolicy class for details.

Parameters:
- *name*: name of destination domain Postfix will lookup. See TLS_README.
- *value*: right-hand part of the tls_policy map
- *ensure*: present/absent, defaults to present.

Requires:
- Class["postfix"]
- Class["postfix::tlspolicy"]

Example usage:

  node "toto.example.com" {
    class { 'postfix':
      manage_tls_policy => 'yes',
    }
    postfix::tlspolicy_snippet {
      'example.com':  value => 'encrypt';
      '.example.com': value => 'encrypt';
      'nothing.com':  value => 'fingerprint match=2A:FF:F0:EC:52:04:99:45:73:1B:C2:22:7F:FD:31:6B:8F:07:43:29';
    }
  }

*/

define postfix::tlspolicy_snippet ($ensure="present", $value = false) {

  if ($value == false) and ($ensure == "present") {
    fail("The value parameter must be set when using the postfix::tlspolicy_snippet define with ensure=present.")
  }

  include postfix::tlspolicy

  concat::fragment { "postfix_tlspolicy_${name}":
    ensure  => "$ensure",
    content => "${name}		${value}\n",
    target  => "$postfix::tlspolicy::postfix_merged_tlspolicy",
  }

}
