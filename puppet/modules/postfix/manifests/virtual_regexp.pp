#
# == Class: postfix::virtual_regexp
#
# Manages Postfix virtual_regexp by merging snippets shipped:
# - in the module's files/virtual_regexp.d/ or puppet:///files/etc/postfix/virtual_regexp.d
#   (the latter takes precedence if present); site_postfix module is supported
#   as well, see the source argument of file {"$postfix_virtual_regexp_snippets_dir"
#   bellow for details.
# - via postfix::virtual_regexp_snippet defines
#
# Example usage:
# 
#   node "toto.example.com" {
#     class { 'postfix':
#       manage_virtual_regexp => 'yes',
#     }
#     postfix::config { "virtual_alias_maps":
#       value => 'hash://postfix/virtual, regexp:/etc/postfix/virtual_regexp',
#     }
#   }
#
class postfix::virtual_regexp {

  include common::moduledir
  common::module_dir{'postfix/virtual_regexp': }

  $postfix_virtual_regexp_dir          = "${common::moduledir::module_dir_path}/postfix/virtual_regexp"
  $postfix_virtual_regexp_snippets_dir = "${postfix_virtual_regexp_dir}/virtual_regexp.d"
  $postfix_merged_virtual_regexp       = "${postfix_virtual_regexp_dir}/merged_virtual_regexp"

  file {"$postfix_virtual_regexp_snippets_dir":
    ensure  => 'directory',
    owner   => 'root',
    group   => '0',
    mode    => '700',
    source  => [
                "puppet:///modules/site_postfix/${fqdn}/virtual_regexp.d",
                "puppet:///modules/site_postfix/virtual_regexp.d",
                "puppet:///files/etc/postfix/virtual_regexp.d",
                "puppet:///modules/postfix/virtual_regexp.d",
               ],
    recurse => true,
    purge   => false,
  }

  concatenated_file { "$postfix_merged_virtual_regexp":
    dir     => "${postfix_virtual_regexp_snippets_dir}",
    require => File["$postfix_virtual_regexp_snippets_dir"],
  }
  
  config_file { '/etc/postfix/virtual_regexp':
    source    => "$postfix_merged_virtual_regexp",
    subscribe => File["$postfix_merged_virtual_regexp"],
  }

}
