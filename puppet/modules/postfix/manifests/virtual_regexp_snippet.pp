/*
== Definition: postfix::virtual_regexp_snippet

Adds a virtual_regexp snippets to /etc/postfix/virtual_regexp.
See the postfix::virtual_regexp class for details.

Parameters:
- *source* or *content*: source or content of the virtual_regexp snippet
- *ensure*: present (default) or absent

Requires:
- Class["postfix"]

Example usage:

  node "toto.example.com" {
    class { 'postfix': }
    postfix::virtual_regexp {
      'wrong_date': content => 'FIXME';
      'bla':        source => 'puppet:///files/etc/postfix/virtual_regexp.d/bla';
    }
  }

*/

define postfix::virtual_regexp_snippet (
  $ensure  = "present",
  $source = '',
  $content = undef
) {

  if $source == '' and $content == undef {
    fail("One of \$source or \$content must be specified for postfix::virtual_regexp_snippet ${name}")
  }

  if $source != '' and $content != undef {
    fail("Only one of \$source or \$content must specified for postfix::virtual_regexp_snippet ${name}")
  }

  if ($value == false) and ($ensure == "present") {
    fail("The value parameter must be set when using the postfix::virtual_regexp_snippet define with ensure=present.")
  }

  include postfix::virtual_regexp

  $snippetfile = "${postfix::virtual_regexp::postfix_virtual_regexp_snippets_dir}/${name}"
  
  file { "$snippetfile":
    ensure  => "$ensure",
    mode    => 600,
    owner   => root,
    group   => 0,
    notify => Exec["concat_${postfix::virtual_regexp::postfix_merged_virtual_regexp}"],
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
