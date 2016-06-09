/*
== Definition: postfix::transport_regexp_snippet

Adds a transport_regexp snippets to /etc/postfix/transport_regexp.
See the postfix::transport_regexp class for details.

Parameters:
- *source* or *content*: source or content of the transport_regexp snippet
- *ensure*: present (default) or absent

Requires:
- Class["postfix"]

Example usage:

  node "toto.example.com" {
    class { 'postfix': }
    postfix::transport_regexp {
      'wrong_date': content => 'FIXME';
      'bla':        source => 'puppet:///files/etc/postfix/transport_regexp.d/bla';
    }
  }

*/

define postfix::transport_regexp_snippet (
  $ensure  = "present",
  $source = '',
  $content = undef
) {

  if $source == '' and $content == undef {
    fail("One of \$source or \$content must be specified for postfix::transport_regexp_snippet ${name}")
  }

  if $source != '' and $content != undef {
    fail("Only one of \$source or \$content must specified for postfix::transport_regexp_snippet ${name}")
  }

  if ($value == false) and ($ensure == "present") {
    fail("The value parameter must be set when using the postfix::transport_regexp_snippet define with ensure=present.")
  }

  include postfix::transport_regexp

  $snippetfile = "${postfix::transport_regexp::postfix_transport_regexp_snippets_dir}/${name}"
  
  file { "$snippetfile":
    ensure  => "$ensure",
    mode    => 600,
    owner   => root,
    group   => 0,
    notify => Exec["concat_${postfix::transport_regexp::postfix_merged_transport_regexp}"],
  }

  if $source {
    File["$snippetfile"] {
      source => $source,
    }
  }
  else {
    File["$snippetfile"] {
      content => $content,
    }
  }

}
