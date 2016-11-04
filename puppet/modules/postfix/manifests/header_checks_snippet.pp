/*
== Definition: postfix::header_checks_snippet

Adds a header_checks snippets to /etc/postfix/header_checks.
See the postfix::header_checks class for details.

Parameters:
- *source* or *content*: source or content of the header_checks snippet
- *ensure*: present (default) or absent

Requires:
- Class["postfix"]

Example usage:

  node "toto.example.com" {
    class { 'postfix': }
    postfix::header_checks_snippet {
      'wrong_date': content => 'FIXME';
      'bla':        source => 'puppet:///files/etc/postfix/header_checks.d/bla';
    }
  }

*/

define postfix::header_checks_snippet (
  $ensure  = "present",
  $source = '',
  $content = undef
) {

  if $source == '' and $content == undef {
    fail("One of \$source or \$content must be specified for postfix::header_checks_snippet ${name}")
  }

  if $source != '' and $content != undef {
    fail("Only one of \$source or \$content must specified for postfix::header_checks_snippet ${name}")
  }

  include postfix::header_checks

  $fragment = "postfix_header_checks_${name}"

  concat::fragment { "$fragment":
    ensure  => "$ensure",
    target  => '/etc/postfix/header_checks',
  }

  if $source {
    Concat::Fragment["$fragment"] {
      source => $source,
    }
  }
  else {
    Concat::Fragment["$fragment"] {
      content => $content,
    }
  }

}
