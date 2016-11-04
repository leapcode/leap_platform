#
# == Class: postfix::header_checks
#
# Manages Postfix header_checks by merging snippets configured
# via postfix::header_checks_snippet defines
#
# Note that this class is useless when used directly.
# The postfix::header_checks_snippet defines takes care of importing
# it anyway.
#
class postfix::header_checks {

  concat { '/etc/postfix/header_checks':
    owner => root,
    group => root,
    mode  => '0600',
  }

  postfix::config { "header_checks":
    value   => 'regexp:/etc/postfix/header_checks',
    require => Concat['/etc/postfix/header_checks'],
  }

  # Cleanup previous implementation's internal files
  include common::moduledir
  file { "${common::moduledir::module_dir_path}/postfix/header_checks":
    ensure  => absent,
    recurse => true,
    force   => true,
  }

}
